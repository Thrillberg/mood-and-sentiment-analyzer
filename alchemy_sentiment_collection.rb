require './alchemyapi'
require 'sqlite3'

# Run this code to 
@db = SQLite3::Database.new "db/collection.sqlite3"
@all_entries = @db.execute "SELECT * FROM tweet_texts"
alchemyapi = AlchemyAPI.new()

@all_entries.each do |entry|
  entry_id = entry[0]
  begin
    response = alchemyapi.sentiment('text', entry[3])
    sentiment = response['docSentiment']['type']

    @db.execute "UPDATE tweet_texts SET alchemy = ? WHERE ID=#{entry_id}", sentiment
  rescue
    next
  end
end
