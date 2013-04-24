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
    limit = params.has_key?(:limit) ? params[:limit] : 10
    offset = params.has_key?(:offset) ? params[:offset] : 0

    if params.has_key?(:url)
      feed = Feed.where(:url => params["url"]).first

      if feed.blank?
        feed = Feed.create(:url=>params["url"])
        print "made feed"
      else
        print "found feed"
      end

      feed.parse_feed_items

      # Limit item count
      requested_items = feed.feed_items.reload.order("published desc").limit(limit).offset(offset)

      return render :json => requested_items
    end


    if params.has_key?(:name)
      requested_items = Feed.where("name like ?", "%#{params[:name]}%")
    else
      requested_items = Feed.where("feeds.default=? AND name IS NOT NULL", true)
    end

    requested_items = requested_items.limit(limit).offset(offset)
    
    matching_feeds = {:feeds => requested_items}
    return render :json=> matching_feeds
  end
  
  # Get /feeds/:id

  def show
    render :json=>Feed.find(params[:id])
  end

  def recommended
    return render :json=> matching_feeds = {:feeds => Feed.where('name IS NOT NULL').sample(2)}
  end

  def combined
    # Throw 404 if no params were passed
    raise ActionController::RoutingError.new('Not Found') if !params.has_key?(:ids)
    
    # Get limit and offset
    limit = params.has_key?(:limit) ? params[:limit] : 10
    offset = params.has_key?(:offset) ? params[:offset] : 0

    render :json=> FeedItem.where('feed_id' => params[:ids]).order("published desc").limit(limit).offset(offset)
    
  end
end
