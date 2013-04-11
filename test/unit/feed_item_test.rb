require 'test_helper'

class FeedItemTest < ActiveSupport::TestCase
  test "FeedItems are required to have a name" do
    f = FeedItem.new(:url=>"http://cloudspace.com")
    assert_equal false, f.valid?
  end
  
  test "FeedItems are required to have a url" do
    f = FeedItem.new(:name=>"Cloudspace Home Page")
    assert_equal false, f.valid?
  end
end
