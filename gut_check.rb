require 'sqlite3'

@db = SQLite3::Database.new "db/collection.sqlite3"
@valid_entries = @db.execute "SELECT * FROM tweet_texts WHERE id BETWEEN 1 AND 250"

@sentimental_sentiment_count = 0
@davies_sentiment_count = 0
@alchemy_sentiment_count = 0

@valid_entries.each do |entry|
  sentimental_sentiment = entry[5]
  if entry[6] > entry[7]
    davies_sentiment = "positive"
  elsif entry[6] < entry[7]
    davies_sentiment = "negative"
  else
    davies_sentiment = "neutral"
  end
  alchemy_sentiment = entry[8]
  eric_sentiment = entry[9]

  if sentimental_sentiment == eric_sentiment
    @sentimental_sentiment_count += 1
  elsif davies_sentiment == eric_sentiment
    @davies_sentiment_count += 1
  elsif alchemy_sentiment == eric_sentiment
    @alchemy_sentiment_count += 1
  end
end

puts "Sentimental: #{@sentimental_sentiment_count.to_f/250.to_f*100}%"
puts "Davies: #{@davies_sentiment_count.to_f/250.to_f*100}%"
puts "Alchemy: #{@alchemy_sentiment_count.to_f/250.to_f*100}%"
