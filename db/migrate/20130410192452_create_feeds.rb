class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :url
      t.string :category, :null => true
      t.string :description, :null => true
      t.string :thumbnail, :null => true

      t.timestamps
    end
  end
end
