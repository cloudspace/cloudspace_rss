require 'feedzirra'
require 'readability'
require 'open-uri'
require 'thread'


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

      if (feed.feed_items.count == 0)
        #Parse the feed, get the feeditems
        feedContent = Feedzirra::Feed.fetch_and_parse(feed.url)
        
        # Create a workers array and mutex for handling multple threads
        workers = Array.new()
        mutex = Mutex.new

        for entry in feedContent.entries
          # Spawn new theads to download and parse the documents in paralell
          thread = Thread.new { 
            # Get readability content
            readability_content = nil
            readability_image = nil
            
            begin
              source = open(entry.url).read
              rbody = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true)

              readability_content = rbody.content
              readability_image = rbody.images[0]
            rescue => e
              # if something went wrong with getting the content just ignore it
            end
          
            # Synchronize theads over the critical section
            mutex.synchronize do
              # Create feed item
              newItem = FeedItem.create(
                :name=>entry.title,
                :url=>entry.url,
                :description=>entry.summary,
                :feed_id=>feed.id,
                :readability_content => readability_content,
                :readability_image => readability_image,
                )
            end
          }

          workers << thread
        end

        # Wait for worker threads to finish
        for worker in workers
          worker.join()
        end
        
        requested_items = feed.feed_items
        
      else
        requested_items = FeedItem.with_feed_url(params["url"])
      end
      
      if params.has_key?(:limit)
        requested_items = requested_items.limit(params[:limit])
        if params.has_key?(:offset)
          requested_items = requested_items.offset(params[:offset])
        end
      end
      
      return render :json => requested_items
    end


    if params.has_key?(:name)
      matching_feeds = {:feeds => Feed.where(['name like ?', "#{params[:name]}%"])}
    else
      matching_feeds = {:feeds => Feed.where(['name IS NOT NULL'])}
    end
    
    return render :json=> matching_feeds
  end
  
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
