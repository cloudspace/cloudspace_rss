class Feed < ActiveRecord::Base
  attr_accessible :category, :description, :name, :thumbnail, :url
end
