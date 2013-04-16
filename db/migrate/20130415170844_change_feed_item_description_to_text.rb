class ChangeFeedItemDescriptionToText < ActiveRecord::Migration
  def up
    change_column(:feed_items, :readability_content, :text)
  end

  def down
    change_column(:feed_items, :readability_content, :string)
  end
end
