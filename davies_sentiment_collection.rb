require 'sqlite3'
require_relative "dictionaries/davies_sentiment_analysis.rb"

@db = SQLite3::Database.new "db/collection.sqlite3"
@all_entries = @db.execute "SELECT * FROM tweet_texts"

@all_entries.each do |entry|
  entry_id = entry[0]
  happy_log_probs, sad_log_probs = read_sentiment_list('twitter_sentiment_list.csv')
  prob_happy = (classify_sentiment(entry[3].split(' '), happy_log_probs, sad_log_probs))[0]
  prob_sad = (classify_sentiment(entry[3].split(' '), happy_log_probs, sad_log_probs))[1]
  @db.execute "UPDATE tweet_texts SET davies_sentiment = ? WHERE ID=#{entry_id}", prob_happy
  @db.execute "UPDATE tweet_texts SET davies_sentiment_sad = ? WHERE ID=#{entry_id}", prob_sad
end
