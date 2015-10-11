require 'open-uri'
require 'sqlite3'
require 'twitter'
require 'mechanize'
require 'dotenv'

Dotenv.load "application.env"
@db = SQLite3::Database.new "db/collection.sqlite3"
client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV["TWITTER_KEY"]
  config.consumer_secret = ENV["TWITTER_SECRET"]
end

politicians = ["@HillaryClinton", "@HillaryClinton's", "@realDonaldTrump", "@realDonaldTrump's", "Clinton", "Clinton's", "Trump", "Trump's", "Hillary", "Hillary's"]

def to_formal_name(feed)
  formal_feed_name = ""
  if feed == "cnnpolitics"
    formal_feed_name = "CNN Politics"
  elsif feed == "cbspolitics"
    formal_feed_name = "CBS Politics"
  elsif feed == "breitbartnews"
    formal_feed_name = "Breitbart News"
  elsif feed == "huffpostpol"
    formal_feed_name = "Huffington Post Politics"
  elsif feed == "politico"
    formal_feed_name = "Politico"
  end
  formal_feed_name
end

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_tweets(user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

def extraction(politicians, tweets, feed)
  tweets.each do |tweet|
    politicians.each do |politician|
      begin
        if tweet.text.downcase.split(' ').include?(politician.downcase)
          agent = Mechanize.new
          img_url = tweet.text.scan(/http[^>]*/).flatten[0].split(' ').last
          page = agent.get(img_url)
          if feed == "cnnpolitics" || feed == "huffpostpol" || feed == "politico"
            img_url = page.image_with(:src => /small/).src.gsub(":small", "")
          elsif feed == "cbspolitics" || feed == "breitbartnews"
            img_url = page.images.first.src
          end
          statement = "INSERT INTO trump_clinton_collection (twitter_account, img_url, politician, text, date) VALUES (\"#{to_formal_name(feed)}\", \"#{img_url}\", \"#{politician}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
          require 'pry';binding.pry
          # @db.execute statement
        end
      rescue
        next
      end 
    end
  end
end

def collect(feed)
  require 'pry';binding.pry
  tweets = client.get_tweets(feed)
  extraction(politicians, tweets, feed)
end

collect("cnnpolitics")
collect("cbspolitics")
collect("breitbartnews")
collect("huffpostpol")
collect("politico")
