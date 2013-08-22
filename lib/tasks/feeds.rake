require 'thread'

namespace :feeds do
  task :clean => :environment do
    Feed.clean
  end
  
  task :purge => :environment do
    FeedItems.purge_old_records
  end

  task :parse => :environment do
    puts "Parsing feeds"
    feeds = Feed.all

    # feedQueue = Queue.new

    # feeds.each do |feed|
    #   feedQueue.push feed
    # end
    
    threads = []
    mutex = Mutex.new

    #start worker threads to process images
    5.times do |index|
      threads << Thread.new(index) { |_threadIndex|
        while (!feeds.empty?) do
          _feed = nil
          
          mutex.synchronize do
            _feed = feeds.pop
            puts "[" + _threadIndex.to_s + "] Parsing " + _feed.url
          end

          _feed.parse_feed_items
        end
      }
    end

    # Wait for threads to finish and reset threads array
    threads.each(&:join)

    FeedItems.purge_old_records

    puts "Done Parsing"

  end
end