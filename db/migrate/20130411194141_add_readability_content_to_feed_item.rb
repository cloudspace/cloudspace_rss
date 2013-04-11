class AddReadabilityContentToFeedItem < ActiveRecord::Migration
  def change
    add_column :feed_items, :readability_content, :string
    add_column :feed_items, :readability_image,   :string
  end
end
