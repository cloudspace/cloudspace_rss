require 'feedzirra'
require 'readability'
require 'open-uri'


class FeedsController < ApplicationController
  # GET /feeds
  def index    
    if params.has_key?(:name)
      matching_feeds = Feed.where(['name like ?', "#{params[:name]}%"])
    else
      matching_feeds = Feed.all
    end
    
    render :json=> matching_feeds
  end
  
  def show
    render :json=>Feed.find(params[:id])
  end
  
  # POST /feeds
  def create
    
    f = Feed.new(:name=>params["name"], :url=>params["url"])
    
    

    if f.save
      #Parse the feed, get the feeditems
      feed = Feedzirra::Feed.fetch_and_parse(f.url)

      
      feed.sanitize_entries!
      
      for entry in feed.entries
        # Get readability content
        readability_content = nil
        readability_image = nil

        begin
          source = open(entry.url).read
          rbody = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true)

          readability_content = rbody.content
          readability_image = rbody.images[0]
        rescue => e
        end

        

        # Create feed item
        newItem = FeedItem.create(
          :name=>entry.title,
          :url=>entry.url,
          :description=>entry.summary,
          :feed_id=>f.id,
          :readability_content => readability_content,
          :readability_image => readability_image,
          )
      end
      
      render :json => f.feed_items
    else
      render :json => FeedItem.with_feed_url(params["url"])
    end
    
  end
end
