require 'open-uri'
require 'sqlite3'
require 'twitter'
require 'nokogiri'
require 'dotenv'
require 'gruff'
require_relative 'collection.rb'
require_relative 'sentiment_analysis.rb'
require_relative 'sentimental.rb'
require_relative 'davies.rb'
require_relative 'alchemy.rb'

database = "db/test.sqlite3"

POLITICIANS = {
  "Hillary Clinton"  => ["@HillaryClinton", "@HillaryClinton's", "Clinton", "Clinton's", "Hillary", "Hillary's"],
  "Donald Trump"     => ["@realDonaldTrump", "@realDonaldTrump's", "Trump", "Trump's"] 
}

TWITTER_FEEDS = {
  "breitbartnews"    => "Breitbart News",
  "cbspolitics"      => "CBS Politics",
  "cnnpolitics"      => "CNN Politics",
  "huffpostpolitics" => "Huffington Post",
  "politico"         => "Politico"
}

TWITTER_FEEDS.keys.each do |feed|
  TweetCollection.new(database, feed).collect_tweets_and_data
end

Sentimental.new(database).make_chart
Davies.new(database).make_chart
Alchemy.new(database).make_chart