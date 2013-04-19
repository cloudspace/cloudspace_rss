require 'memcached'
$cache = Memcached.new("localhost:11211")

class Feed < ActiveRecord::Base
  attr_accessible :category, :description, :name, :thumbnail, :url, :default
  validates_presence_of  :url
  validates_uniqueness_of :url
  has_many :feed_items
  
  def parse_feed_items 
    #Parse the feed, get the feeditems
    puts "Loading feed"
    begin
      feedContent = $cache.get "feed" + self.url
    rescue ::Memcached::NotFound
      feedContent = Feedzirra::Feed.fetch_and_parse(self.url)
      $cache.set "feed"+self.url, feedContent, 300
    end
    

    #The view for rendering to a string
    #ac = ActionController::Base.new()
    
    # Create a workers array and mutex for handling multple threads
    #mutex = Mutex.new
    #threads = []
    #newFeedRecords = []

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

    # puts "Finding thumbnails"
    # #start worker threads to process images
    # 15.times do |index|
    #   threads << Thread.new(index) { |_threadIndex|
    #     while (!newFeedItemQueue.empty?) do
    #       feedItem = newFeedItemQueue.pop

    #       summaryReadability = Readability::Document.new(feedItem.description, :tags => %w[img], :attributes => %w[src], :remove_empty_nodes => true)
    #       summaryReadabilityImage = summaryReadability.images[0]

    #       if summaryReadabilityImage
    #         feedItem.readability_image = summaryReadabilityImage
    #       end


    #       mutex.synchronize do
    #         newFeedRecords << feedItem
    #       end
    #     end
    #   }
    # end

    # # # Wait for threads to finish and reset threads array
    # threads.each(&:join)

    # puts "Saving"
    # for record in newFeedRecords
    #   record.save
    # end
  end
  
end
