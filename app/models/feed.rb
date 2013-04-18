class Feed < ActiveRecord::Base
  attr_accessible :category, :description, :name, :thumbnail, :url, :default
  validates_presence_of  :url
  validates_uniqueness_of :url
  has_many :feed_items
  
  def parse_feed_items
    
    #Parse the feed, get the feeditems
    feedContent = Feedzirra::Feed.fetch_and_parse(self.url)
    
    #The view for rendering to a string
    ac = ActionController::Base.new()
    
    # Create a workers array and mutex for handling multple threads
    mutex = Mutex.new
    threads = []
    processed_entries = []

    existing_entry_urls = self.feed_items.collect{|existing_entry| existing_entry.url}

    for feedEntry in feedContent.entries
      # Skip entries that have already been processed

      if existing_entry_urls.include? feedEntry.url
        puts "Entry " + feedEntry.url + " already exists for this feed"
        next
      end
      
      f_record = FeedItem.new

      threads << Thread.new(feedEntry, f_record) { |entry, feed_record|

        readability_content = nil
        readability_image = nil
        thumbnail = nil

        mutex.synchronize do
          puts "Loading " + entry.url
        end

        begin
          source = open(entry.url).read
          rbody = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true)

          readability_content = rbody.content
          readability_image = rbody.images[0]
          
          if readability_image
            thumb_image = MiniMagick::Image.open(readability_image)
            thumbnail = FeedsHelper::upload_thumbnail_to_aws(FeedsHelper::resize_and_crop(thumb_image, 88), 'cloudspace_rss_thumbs')
          end
        rescue => e
          # if something went wrong with getting the content just ignore it
          puts e
        end

         mutex.synchronize do
          puts "Finished " + entry.url
        end

        # Synchronize theads over the critical section
        mutex.synchronize do
          puts "Starting record save for " + entry.title
          feed_record.name = entry.title
          feed_record.url = entry.url
          feed_record.description = entry.summary
          feed_record.feed_id = self.id
          puts "Starting render for " +entry.title
          feed_record.readability_content = ac.render_to_string(
            :template=>"layouts/feeditem",
            :locals=>{
              :readability_image=>readability_image,
              :readability_content=>readability_content,
              :entry_summary=>entry.summary,
              :entry_name=>entry.title,
            }
          )
          feed_record.readability_image = readability_image
          feed_record.image = @thumbnail
          feed_record.published = entry.published
          feed_record.save
      
          puts "Finished saving feed_record for " + entry.title
        end
      }
    end
    # Wait for worker threads to finish
    threads.each(&:join)
    
  end
  
end
