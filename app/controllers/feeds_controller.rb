require 'feedzirra'

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
  
  # POST /feeds
  def create
    
    f = Feed.new(:name=>params["name"], :url=>params["url"])
    
    if f.save
      #Parse the feed, get the feeditems
      feed = Feedzirra::Feed.fetch_and_parse(f.url)
      feed.sanitize_entries!
      
      for entry in feed.entries
        FeedItem.create(:name=>entry.title, :url=>entry.url, :description=>entry.content, :feed_id=>f.id)
      end
      
      render :json => f.feed_items
    else
      render :json => FeedItem.with_feed_url(params["url"])
    end
    
  end
end
