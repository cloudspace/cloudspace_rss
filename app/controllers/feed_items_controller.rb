require 'readability'
require 'memcached'
$cache = Memcached.new("localhost:11211")

class FeedItemsController < ApplicationController
  # GET /feed_items
  def index    
    if params.has_key?(:feed_url) and params.has_key?(:item_url)
      feed = Feed.where('url=?', params[:feed_url])[0]
      item = FeedItem.where('url=? and feed_id=?', params[:item_url], feed.id)[0]

      if(item and not item.readability_content)
        
        source = open(item.url).read
        rbody = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true)

        readability_content = rbody.content
        readability_image = rbody.images[0]
        entry_summary = item.description
        entry_name = item.name
          
        if readability_image
          thumb_image = MiniMagick::Image.open(readability_image)
          thumbnail = FeedsHelper::upload_thumbnail_to_aws(FeedsHelper::resize_and_crop(thumb_image, 88), 'cloudspace_rss_thumbs')
        end
        
        item.readability_content = self.render_to_string( :template=>"layouts/feeditem",
          :locals=> {
            :readability_content=> readability_content,
            :readability_image=> readability_image,
            :entry_summary=> entry_summary,
            :entry_name=> entry_name
          })
        item.readability_image = readability_image
        item.image = thumbnail
        
        item.save
      end
      
      render :json=> item
    end
  end

  # Returns the s3 link to the appropriate thumbnail
  # Generate the thumbnail if it doesn't exist
  def thumbnail
    feedItem = FeedItem.where("id = ?", params[:id]).limit(1).first rescue nil
    
    # 33.33.33.107:3000/feed_items/242/thumbnail

    if (feedItem)
      # If a readbility image exists but no thumbnail has been generated, generate one and upload it
      if !feedItem.image || true
        begin
          puts "Finding thumbnail for " + feedItem.url

          # Check feed description for images before anything else
          doc = Nokogiri::HTML(feedItem.description)
          
          summaryImages = doc.xpath("//img/@src")
          if !summaryImages.empty?
            summaryImage = summaryImages.first.value
            puts summaryImage
                # end

                # #summaryReadability = Readability::Document.new(feedItem.description, :tags => %w[img], :attributes => %w[src], :remove_empty_nodes => true)
                # #summaryReadabilityImage = summaryReadability.images[0]

                # if (summaryImage)
            begin
              cachedResult = $cache.get summaryImage
              feedItem.image = cachedResult

            rescue ::Memcached::NotFound
              puts "Generating and uploading thumbnail for " + feedItem.url
              feedItem.readability_image = summaryImage

              thumbImage = FeedsHelper::resize_and_crop(MiniMagick::Image.open(feedItem.readability_image), 88)
              thumbnailURL = FeedsHelper::upload_thumbnail_to_aws(thumbImage, 'cloudspace_rss_thumbs')  

              feedItem.image = thumbnailURL
              feedItem.save

              $cache.set summaryImage, thumbnailURL
            end
          end
        rescue => e
          puts 'ERROR' + e.to_s
          # Ignore errors
        end
      end

      # Redirect to the thumbnail if it exists
      if feedItem.image
        redirect_to feedItem.image
        return
      end
    end

    # No images available, render 404
    redirect_to "http://images.wikia.com/runescape/images/2/21/1x1-pixel.png"
  end  

  # GET /feed_items/:id
  def show
    render :json=>FeedItem.find(params[:id])
  end
  
end
