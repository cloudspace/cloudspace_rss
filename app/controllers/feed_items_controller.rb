require 'readability'
require 'memcached'
$cache = Memcached.new("localhost:11211")

class FeedItemsController < ApplicationController
  # GET /feed_items
  def index    
    if params.has_key?(:feed_url) and params.has_key?(:item_url)
      feed = Feed.where('url=?', params[:feed_url])[0]
      item = FeedItem.where('url=? and feed_id=?', params[:item_url], feed.id)[0]

      if(item and not item.readability_content)
        
        source = open(item.url).read
        rbody = Readability::Document.new(source, :tags => %w[div p img a], :attributes => %w[src href], :remove_empty_nodes => true)

        readability_content = rbody.content
        readability_image = rbody.images[0]
        entry_summary = item.description
        entry_name = item.name
          
        if readability_image
          thumb_image = MiniMagick::Image.open(readability_image)
          thumbnail = FeedsHelper::upload_thumbnail_to_aws(FeedsHelper::resize_and_crop(thumb_image, 88), 'cloudspace_rss_thumbs')
        end
        
        item.readability_content = self.render_to_string( :template=>"layouts/feeditem",
          :locals=> {
            :readability_content=> readability_content,
            :readability_image=> readability_image,
            :entry_summary=> entry_summary,
            :entry_name=> entry_name
          })
        item.readability_image = readability_image
        item.image = thumbnail
        
        item.save
      end
      
      render :json=> item
    end
  end

  # Returns the s3 link to the appropriate thumbnail
  # Generate the thumbnail if it doesn't exist
  def thumbnail
    feedItem = FeedItem.where("id = ?", params[:id]).limit(1).first rescue nil
    
    if (feedItem)
      # Generate a thumbnail image if none exists
      feedItem.generate_thumbnail if !feedItem.image

      return redirect_to feedItem.image
    else
      return redirect_to "file:///"
    end
  end  
end
