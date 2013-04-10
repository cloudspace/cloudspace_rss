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
end
