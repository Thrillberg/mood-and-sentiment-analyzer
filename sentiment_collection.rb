require 'sqlite3'
require_relative "sentiment_analysis.rb"

@db = SQLite3::Database.new "collection.sqlite3"
@all_entries = @db.execute "SELECT * FROM tweet_texts"

@all_entries.each do |entry|
  entry_id = entry[0]
  entry_sentiment = (get_sentiment entry[3]).to_s
  @db.execute "UPDATE tweet_texts SET sentiment = ? WHERE ID=#{entry_id}", entry_sentiment
end
