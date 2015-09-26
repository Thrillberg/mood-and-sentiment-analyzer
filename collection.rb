require 'open-uri'
require 'sqlite3'
require 'twitter'
require 'mechanize'
require 'dotenv'

Dotenv.load "application.env"
@db = SQLite3::Database.new "collection.sqlite3"
client = Twitter::REST::Client.new do |config|
  config.consumer_key    = ENV["TWITTER_KEY"]
  config.consumer_secret = ENV["TWITTER_SECRET"]
end

require 'pry';binding.pry

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

def cnnpolitics_extraction(politicians, tweets)
  tweets.each do |tweet|
    politicians.each do |politician|
      begin
        if tweet.text.downcase.split(' ').include?(politician.downcase)
          img_url = tweet.text.scan(/http[^>]*/).flatten[0].split(' ').last
          agent = Mechanize.new
          page = agent.get(img_url)
          img_url = page.image_with(:src => /small/).src.gsub(":small", "")
          statement = "INSERT INTO trump_clinton_collection (twitter_account, img_url, politician, text, date) VALUES (\"CNN Politics\", \"#{img_url}\", \"#{politician}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
          @db.execute statement
        end
      rescue
        next
      end 
    end
  end
end

def huffpostpol_extraction(politicians, tweets)
  tweets.each do |tweet|
    politicians.each do |politician|
      begin
        if tweet.text.downcase.split(' ').include?(politician.downcase)
          img_url = tweet.text.scan(/http[^>]*/).flatten[0].split(' ').last
          agent = Mechanize.new
          page = agent.get(img_url)
          img_url = page.image_with(:src => /small/).src.gsub(":small", "")
          statement = "INSERT INTO trump_clinton_collection (twitter_account, img_url, politician, text, date) VALUES (\"Huffington Post Politics\", \"#{img_url}\", \"#{politician}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
          @db.execute statement
        end
      rescue
        next
      end 
    end
  end
end

def cbspolitics_extraction(politicians, tweets)
  tweets.each do |tweet|
    politicians.each do |politician|
      begin
        if tweet.text.downcase.split(' ').include?(politician.downcase)
          img_url = tweet.text.match(/http[^>]*/).to_s
          agent = Mechanize.new
          page = agent.get(img_url)
          img_url = page.images.first.src
          statement = "INSERT INTO trump_clinton_collection (twitter_account, img_url, politician, text, date) VALUES (\"CBS Politics\", \"#{img_url}\", \"#{politician}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
          @db.execute statement
        end
      rescue
        next
      end 
    end
  end
end

def breitbartnews_extraction(politicians, tweets)
  tweets.each do |tweet|
    politicians.each do |politician|
      begin
        if tweet.text.downcase.split(' ').include?(politician.downcase)
          img_url = tweet.text.match(/http\S*/).to_s
          agent = Mechanize.new
          page = agent.get(img_url)
          img_url = page.images.first.src
          statement = "INSERT INTO trump_clinton_collection (twitter_account, img_url, politician, text, date) VALUES (\"Breitbart News\", \"#{img_url}\", \"#{politician}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
          @db.execute statement
        end
      rescue
        next
      end 
    end
  end
end

def politico_extraction(politicians, tweets)
  tweets.each do |tweet|
    politicians.each do |politician|
      begin
        if tweet.text.downcase.split(' ').include?(politician.downcase)
          img_url = tweet.text.scan(/http[^>]*/).flatten[0].split(' ').last
          agent = Mechanize.new
          page = agent.get(img_url)
          img_url = page.image_with(:src => /small/).src.gsub(":small", "")
          statement = "INSERT INTO trump_clinton_collection (twitter_account, img_url, politician, text, date) VALUES (\"Politico\", \"#{img_url}\", \"#{politician}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
          @db.execute statement
        end
      rescue
        next
      end 
    end
  end
end

politicians = ["@HillaryClinton", "@realDonaldTrump", "Clinton", "Trump", "Hillary"]

cnnpolitics_tweets = client.get_tweets("cnnpolitics")
cnnpolitics_extraction(politicians, cnnpolitics_tweets)

huffpostpol_tweets = client.get_tweets("huffpostpol")
huffpostpol_extraction(politicians, huffpostpol_tweets)

cbspolitics_tweets = client.get_tweets("cbspolitics")
cbspolitics_extraction(politicians, cbspolitics_tweets)

breitbartnews_tweets = client.get_tweets("breitbartnews")
breitbartnews_extraction(politicians, breitbartnews_tweets)

politico_tweets = client.get_tweets("politico")
politico_extraction(politicians, politico_tweets)
