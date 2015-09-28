require 'sentimental'
require 'sqlite3'

@db = SQLite3::Database.new "collection.sqlite3"
@all_entries = @db.execute "SELECT * FROM trump_clinton_collection"

Sentimental.load_defaults
analyzer = Sentimental.new

@all_entries.each do |entry|
  entry_id = entry[0]
  entry_sentiment = (analyzer.get_sentiment entry[4]).to_s
  @db.execute "UPDATE trump_clinton_collection SET sentiment = ? WHERE ID=#{entry_id}", entry_sentiment
end
