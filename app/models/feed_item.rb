require 'memcached'
$cache = Memcached.new("localhost:11211")

class FeedItem < ActiveRecord::Base
  attr_accessible :description, :image, :name, :url, :feed_id, :readability_content, :readability_image, :published
  validates_presence_of :name, :url
  belongs_to :feed
  
  scope :with_feed_url, lambda { |url| joins(:feed).where('feeds.url = ?', url) }

  def self.purge_old_records
    feeds = Feeds.all
    
    #For every feed, keep only the latest 30 records
    feeds.each do |feed|
      newest_records = feed.feed_items.find(:all, :order => 'created_at DESC', :limit => 200)
      FeedItem.destroy_all(['id NOT IN (?)', newest_records.collect(&:id)])
    end
    
  end

  def generate_thumbnail
    begin
      puts "Generating thumbnail for " + self.url

      # Check feed description for images before anything else
      doc = Nokogiri::HTML(self.description)
      
      summaryImages = doc.xpath("//img/@src")
      if !summaryImages.empty?
        summaryImage = summaryImages.first.value

        begin
          cachedResult = $cache.get summaryImage
          self.image = cachedResult

        rescue ::Memcached::NotFound
          # Generate and upload thumbnail
          self.readability_image = summaryImage

          image = MiniMagick::Image.open(self.readability_image);
          
          if image and image[:height] > 100 && image[:width] > 100

            thumbImage = FeedsHelper::resize_and_crop(image, 88)
            thumbnailURL = FeedsHelper::upload_thumbnail_to_aws(thumbImage, 'cloudspace_rss_thumbs')  

            self.image = thumbnailURL
            self.save

            $cache.set summaryImage, thumbnailURL
          end
        end
      end

      # If none were found in summary try content
      if (!self.image)
        begin
          cachedResult = $cache.get "image"+self.url
          self.image = cachedResult

        rescue ::Memcached::NotFound
          puts "--GETTING THUMBNAIL FROM CONTENT--"
          source = open(self.url).read
          
          readability = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true)

          largestImage = nil
          largestImageSize = 0

          readability.images.each do |image_url|
            begin
              image = MiniMagick::Image.open(image_url);
              puts image_url
              imageSize = image[:width] * image[:height]

              if imageSize > largestImageSize
                largestImage = image
                largestImageSize = imageSize
              end
            rescue Exception
              next
            end
          end

          # Save and crop if image is significant
          if largestImage && largestImageSize > 1000
            thumbImage = FeedsHelper::resize_and_crop(image, 88)
            thumbnailURL = FeedsHelper::upload_thumbnail_to_aws(thumbImage, 'cloudspace_rss_thumbs')  

            self.image = thumbnailURL
            self.save

            $cache.set "image"+self.url, thumbnailURL
          end

          # Generate and upload thumbnail
          self.readability_image = largestImage
        end
      end
    rescue => e
      puts 'ERROR' + e.to_s
      # Ignore errors

      self.image = ""
      self.save
    end
  end
end
