class AddFeedItemToFeed < ActiveRecord::Migration
  def change
    add_column :feed_items, :feed_id, :integer
  end
end
