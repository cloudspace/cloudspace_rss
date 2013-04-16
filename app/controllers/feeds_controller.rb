require 'feedzirra'
require 'readability'
require 'open-uri'
require 'thread'

#require 'socksify'
#TCPSocket::socks_server = "10.0.1.139"
#TCPSocket::socks_port = 8889

class FeedsController < ApplicationController
  # GET /feeds
  def index 
    if params.has_key?(:url)
      feed = Feed.where(:url => params["url"]).first

      if feed.blank?
        feed = Feed.create(:url=>params["url"])
        print "made feed"
      else
        print "found feed"
      end

      #Parse the feed, get the feeditems
      feedContent = Feedzirra::Feed.fetch_and_parse(feed.url)
      
      # Create a workers array and mutex for handling multple threads
      mutex = Mutex.new
      threads = []
      processed_entries = []

      existing_entry_urls = feed.feed_items.collect{|existing_entry| existing_entry.url}

      for feedEntry in feedContent.entries
        # Skip entries that have already been processed

        if existing_entry_urls.include? feedEntry.url
          puts "Entry " + feedEntry.url + " already exists for this feed"
          next
        end

        threads << Thread.new(feedEntry) { |entry|

          readability_content = nil
          readability_image = nil
          
          mutex.synchronize do
            puts "Loading " + entry.url
          end

          begin
            source = open(entry.url).read
            rbody = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true)

            readability_content = rbody.content
            readability_image = rbody.images[0]
          rescue => e
            # if something went wrong with getting the content just ignore it
          end

           mutex.synchronize do
            puts "Finished " + entry.url
          end
        
          # Synchronize theads over the critical section
          mutex.synchronize do
            processed_entries.push ({
              :entry => entry,
              :readability_content => readability_content,
              :readability_image => readability_image
            })
          end

        }
      end

      # Wait for worker threads to finish
      threads.each(&:join)
      
      # Create the active record objects
      # do this here because on the worker threads it will spawn new rails instances for each entry and 
      # take forever
      for e in processed_entries
        entry = e[:entry]

        # Create feed item
        newItem = FeedItem.create(
          :name=>entry.title,
          :url=>entry.url,
          :description=>entry.summary,
          :feed_id=>feed.id,
          :readability_content => e[:readability_content],
          :readability_image => e[:readability_image],
          :published => entry.published
          )
      end
      
      requested_items = feed.feed_items

      # Limit item count
      
      if params.has_key?(:limit)
        requested_items = requested_items.limit(params[:limit])
      end

      if params.has_key?(:offset)
          requested_items = requested_items.offset(params[:offset])
      end
      
      return render :json => requested_items
    end


    if params.has_key?(:name)
      requested_items = Feed.where(['name like ?', "#{params[:name]}%"])
    else
      requested_items = Feed.where(['name IS NOT NULL'])
    end
    
    if params.has_key?(:limit)
      requested_items = requested_items.limit(params[:limit])
    end
    if params.has_key?(:offset)
      requested_items = requested_items.offset(params[:offset])
    end
    
    matching_feeds = {:feeds => requested_items}
    return render :json=> matching_feeds
  end
  
  # Get /feeds/:id

  def show
    render :json=>Feed.find(params[:id])
  end
  
  # # POST /feeds
  # def create
    
  #   f = Feed.new(:name=>params["name"], :url=>params["url"])
    
  #   if f.save
  #     #Parse the feed, get the feeditems
  #     feed = Feedzirra::Feed.fetch_and_parse(f.url)

   
    
  # end
end
