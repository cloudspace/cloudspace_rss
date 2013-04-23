namespace :feeds do
  task :parse => :environment do
    puts "Parsing feeds"
    feeds = Feed.all

    feedQueue = Queue.new

    feeds.each do |feed|
      feedQueue.push feed
      
    end
    
    threads = []
    mutex = Mutex.new

    #start worker threads to process images
    5.times do |index|

      threads << Thread.new(index) { |_threadIndex|
        while (!feedQueue.empty?) do
          _feed = feedQueue.pop

          mutex.synchronize do
            puts "[" + _threadIndex.to_s + "] Parsing " + _feed.url
          end

          _feed.parse_feed_items
        end
      }
    end

    # Wait for threads to finish and reset threads array
    threads.each(&:join)

    puts "Done Parsing"

  end
end