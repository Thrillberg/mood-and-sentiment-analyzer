require 'open-uri'
require 'sqlite3'
require 'twitter'
require 'mechanize'
require 'dotenv'

class TweetCollection
  def initialize(database, feed)
    Dotenv.load "application.env"
    @db = SQLite3::Database.new database
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV["TWITTER_KEY"]
      config.consumer_secret = ENV["TWITTER_SECRET"]
    end

    @feed = feed

    @politicians = {["@HillaryClinton", "@HillaryClinton's", "Clinton", "Clinton's", "Hillary", "Hillary's"] => "Hillary Clinton", ["@realDonaldTrump", "@realDonaldTrump's", "Trump", "Trump's"] => "Donald Trump"}

    @twitter_feeds = {"breitbartnews" => "Breitbart News", "cbspolitics" => "CBS Politics", "cnnpolitics" => "CNN Politics", "huffpostpolitics" => "Huffington Post", "politico" => "Politico"}
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  def get_tweets(client, user)
    collect_with_max_id do |max_id|
      options = {count: 200, include_rts: true}
      options[:max_id] = max_id unless max_id.nil?
      @client.user_timeline(user, options)
    end
  end

  def extract_data(politicians, tweets, feed)
    tweets.each do |tweet|
      politicians.each do |politician|
        politician[0].each do |pol|
          begin
            if tweet.text.downcase.split(' ').include?(pol.downcase)
              agent = Mechanize.new
              img_url = tweet.text.scan(/http[^>]*/).flatten[0].split(' ').last
              page = agent.get(img_url)
              if feed == "cnnpolitics" || feed == "huffpostpol" || feed == "politico"
                img_url = page.image_with(:src => /small/).src.gsub(":small", "")
              elsif feed == "cbspolitics" || feed == "breitbartnews"
                img_url = page.images.first.src
              end
              statement = "INSERT INTO trump_clinton_tweets (twitter_account, img_url, politician, text, date) VALUES (\"#{@twitter_feeds[feed]}\", \"#{img_url}\", \"#{politician[1]}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
              @db.execute statement
            end
          rescue
            next
          end
        end 
      end
    end
  end

  def collect_tweets_and_data
    tweets = get_tweets(@client, @feed)
    extract_data(@politicians, tweets, @feed)
  end
end
