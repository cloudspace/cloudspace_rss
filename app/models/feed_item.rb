class FeedItem < ActiveRecord::Base
  attr_accessible :description, :image, :name, :url, :feed_id, :readability_content, :readability_image, :published
  validates_presence_of :name, :url
  belongs_to :feed
  
  scope :with_feed_url, lambda { |url| joins(:feed).where('feeds.url = ?', url) }

  def self.purge_old_records
    feeds = Feeds.all
    
    #For every feed, keep only the latest 30 records
    feeds.each do |feed|
      newest_records = FeedItem.find(:all, :order => 'created_at DESC', :limit => 30)
      FeedItem.destroy_all(['id NOT IN (?)', newest_records.collect(&:id)])
    end
    
  end
end
