class FeedItem < ActiveRecord::Base
  attr_accessible :description, :image, :name, :url, :feed_id, :readability_content, :readability_image
  validates_presence_of :name, :url
  belongs_to :feed
  
  scope :with_feed_url, lambda { |url| joins(:feed).where('feeds.url = ?', url) }

end
