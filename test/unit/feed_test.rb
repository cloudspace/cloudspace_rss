require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  test "Feeds are required to have a name" do
    f = Feed.new(:url=>"http://cloudspace.com")
    assert_equal false, f.valid?
  end
  
  test "Feeds are required to have a url" do
    f = Feed.new(:name=>"Cloudspace Home Page")
    assert_equal false, f.valid?
  end
end
