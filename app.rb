require 'open-uri'
require 'sqlite3'
require 'twitter'
require 'mechanize'
require 'dotenv'
require_relative 'collection.rb'
require_relative 'sentimental_sentiment_analysis.rb'

database = "db/collection.sqlite3"

TweetCollection.new(database, "cnnpolitics").collect_tweets_and_data
TweetCollection.new(database, "cbspolitics").collect_tweets_and_data
TweetCollection.new(database, "breitbartnews").collect_tweets_and_data
TweetCollection.new(database, "huffpostpol").collect_tweets_and_data
TweetCollection.new(database, "politico").collect_tweets_and_data

SentimentalSentimentAnalysis.new("db/collection.sqlite3").update_database