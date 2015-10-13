require 'open-uri'
require 'sqlite3'
require 'twitter'
require 'nokogiri'
require 'dotenv'
require 'open_uri_redirections'

class TweetCollection
  def initialize(database, feed)
    Dotenv.load "application.env"
    @db = SQLite3::Database.new database
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV["TWITTER_KEY"]
      config.consumer_secret = ENV["TWITTER_SECRET"]
    end
    @feed = feed
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

  def extract_data(tweets, feed)
    tweets.each do |tweet|
      POLITICIANS.each do |politician|
        politician[1].each do |pol|
          begin
            if tweet.text.downcase.split(' ').include?(pol.downcase)
              img_url = tweet.text.scan(/http[^>]*/).flatten[0].split(' ').last
              page = Nokogiri::HTML(open(img_url, :allow_redirections => :all))
              img_url = page.xpath("//meta[@property='og:image']").to_s.match(/(http.*(jpg|png))/)[0]
              statement = "INSERT INTO trump_clinton_tweets (twitter_account, img_url, politician, text, date) VALUES (\"#{@twitter_feeds[feed]}\", \"#{img_url}\", \"#{politician[0]}\", \"#{tweet.text}\", \"#{tweet.created_at}\")"
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
    tweets = get_tweets(@client, "politico")
    extract_data(tweets, "politico")
  end
end
