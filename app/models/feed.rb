require 'www/favicon'

class Feed < ActiveRecord::Base
  attr_accessible :category, :description, :name, :thumbnail, :url, :default
  validates_presence_of  :url
  validates_uniqueness_of :url
  has_many :feed_items, dependent: :destroy

  # generates an image for the feed
  def generate_feed_image
    return self.image if self.image

    uri = URI.parse(self.url)
    host = uri.host.split(".").last(2).join(".")
    faviconurl = WWW::Favicon.new.find "#{uri.scheme}://#{host}"
    favicon = MiniMagick::Image.open(faviconurl)
    sizes = favicon["%w,"].split(",").collect { |size| size.to_i }
    largest_page = sizes.index(sizes.max)
    favicon.format "png", largest_page

    thumbImage = FeedsHelper::resize_and_crop(favicon, 88)
    thumbnailURL = FeedsHelper::upload_thumbnail_to_aws(thumbImage, 'cloudspace_rss_thumbs')

    return thumbnailURL
  end

  # Removes duplicate feeds
  def self.clean
    feeds = Feed.all

    feeds.each do |feed|
      items = feed.feed_items

      links = Array.new

      items.each do |feed_item|
        if links.include? feed_item.url
          feed_item.delete
        else
          links.push feed_item.url
        end
      end
    end
  end

  # Prases feed items
  def parse_feed_items
    begin
      feed_content = Rails.cache.fetch('feed' + self.url, :expires_in => 600) do
        Feedzirra::Feed.fetch_and_parse(self.url)
      end
      
      self.name = feed_content.title
      
      existing_entry_urls = self.feed_items.collect { |existing_entry| existing_entry.url }

      # Generate new feed items
      feed_content.entries.each do |feed_entry|
        # Don't process duplicates
        if existing_entry_urls.include? feed_entry.url
          next
        end

        # Create the initial record
        new_feed_item = FeedItem.new

        new_feed_item.name = feed_entry.title
        new_feed_item.url = feed_entry.url
        new_feed_item.description = feed_entry.summary
        new_feed_item.feed_id = self.id
        new_feed_item.published = feed_entry.published

        new_feed_item.save
      end
    rescue => e
      puts e
    end
  end
  
end
