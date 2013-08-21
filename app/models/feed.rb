require 'memcached'
$cache = Memcached.new("localhost:11211")

class Feed < ActiveRecord::Base
  attr_accessible :category, :description, :name, :thumbnail, :url, :default
  validates_presence_of  :url
  validates_uniqueness_of :url
  has_many :feed_items, dependent: :destroy

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

      #Parse the feed, get the feeditems
      begin
        feedContent = $cache.get "feed" + self.url
      rescue ::Memcached::NotFound
        puts "NOT CACHED, FETCHING"
        feedContent = Feedzirra::Feed.fetch_and_parse(self.url)
        $cache.set "feed"+self.url, feedContent, 600
      end
      
      self.name = feedContent.title
      
      existing_entry_urls = self.feed_items.collect{|existing_entry| existing_entry.url}

      # Generate new feed items
      for feedEntry in feedContent.entries
        # Don't process duplicates
        if existing_entry_urls.include? feedEntry.url
          next
        end

        # Create the initial record
        newFeedItem = FeedItem.new

        newFeedItem.name = feedEntry.title
        newFeedItem.url = feedEntry.url
        newFeedItem.description = feedEntry.summary
        newFeedItem.feed_id = self.id
        newFeedItem.published = feedEntry.published

        newFeedItem.save
      end
    rescue => e
      puts e
    end
  end
  
end
