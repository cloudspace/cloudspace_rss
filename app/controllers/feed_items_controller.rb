class FeedItemsController < ApplicationController
  # GET /feed_items
  def index    
    if params.has_key?(:feed_id)
      feed_items = FeedItem.where('feed_id=?', params[:feed_id])
    else
      feed_items = FeedItem.all
    end
    
    render :json=> feed_items
  end
  
  # GET /feed_items/:id
  def show
    render :json=>FeedItem.find(params[:id])
  end
  
end
