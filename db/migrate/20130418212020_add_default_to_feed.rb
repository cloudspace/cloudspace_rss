class AddDefaultToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :default, :boolean, :default => false
  end
end
