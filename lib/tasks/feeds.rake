namespace :feeds do
  task :parse => :environment do
    puts "Parsing feeds"
    feeds = Feed.all
    feeds.each do |feed|
      feed.parse_feed_items
    end
  end
end