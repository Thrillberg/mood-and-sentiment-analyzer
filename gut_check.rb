require 'sqlite3'

@db = SQLite3::Database.new "db/collection.sqlite3"
@valid_entries = @db.execute "SELECT * FROM tweet_texts WHERE id BETWEEN 1 AND 250"

@sentimental_sentiment_count = 156
@davies_sentiment_count = 156
@alchemy_sentiment_count = 156
@total_entry_count = 0

@valid_entries.each do |entry|
  if entry[9] == "positive" || entry[9] == "negative"
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

    if eric_sentiment == "positive" && sentimental_sentiment == "negative"
      @sentimental_sentiment_count -= 1
    elsif eric_sentiment == "positive" && davies_sentiment == "negative"
      @davies_sentiment_count -= 1
    elsif eric_sentiment == "positive" && alchemy_sentiment == "negative"
      @alchemy_sentiment_count -= 1
    end

    if eric_sentiment == "negative" && sentimental_sentiment == "positive"
      @sentimental_sentiment_count -= 1
    elsif eric_sentiment == "negative" && davies_sentiment == "positive"
      @davies_sentiment_count -= 1
    elsif eric_sentiment == "negative" && alchemy_sentiment == "positive"
      @alchemy_sentiment_count -= 1
    end
  end
end

puts @total_entry_count
puts "Sentimental: #{@sentimental_sentiment_count.to_f/156*100}%"
puts "Davies: #{@davies_sentiment_count.to_f/156*100}%"
puts "Alchemy: #{@alchemy_sentiment_count.to_f/156*100}%"
