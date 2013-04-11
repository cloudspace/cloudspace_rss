class CreateFeedItems < ActiveRecord::Migration
  def change
    create_table :feed_items do |t|
      t.string :name
      t.text :description, :null=>true
      t.string :image, :null=>true
      t.string :url
      t.timestamps
    end
  end
end
