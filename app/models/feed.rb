class Feed < ActiveRecord::Base
  attr_accessible :category, :description, :name, :thumbnail, :url
  validates_presence_of :name, :url
  validates_uniqueness_of :url
  has_many :feed_items
end
