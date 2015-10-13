require './alchemyapi'

class Alchemy < SentimentAnalysis
  def initialize
    super(database)
  end

  def update_database
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
  end

  def make_sentiment_hash(politician, feed, algorithm)
    sentiments = @all_entries.select { |entry| entry[1] == TWITTER_FEEDS[feed] && politician.include?(entry[2]) }
    freq = sentiments.inject(Hash.new(0)) { |h, v| h[v[8]] += 1;h }
  end
end