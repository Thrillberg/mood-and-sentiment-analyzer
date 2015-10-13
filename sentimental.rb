class Sentimental < SentimentAnalysis
  def initialize(database)
    super(database)
    @dictionary = {}
    @algorithm = "sentimental"
    File.open('dictionaries/dictionary.txt', 'r') do |file|
      while(line = file.gets)
        parsed_line = line.chomp.split(' ')
        score = parsed_line[0]
        word = parsed_line[1]
        @dictionary[word] = score.to_f
      end
    end
  end

  def get_score(string)
    sentiment_total = 0.0
    tokens = string.to_s.downcase.split(' ')

    tokens.each do |token|
      begin
        sentiment_total += @dictionary[token]
      rescue
        next
      end
    end
    sentiment_total
  end

  def get_sentiment(string)
    score = get_score(string)

    if score < 0.0
      :negative
    elsif score > 0.0
      :positive
    else
      :neutral
    end
  end

  def update_database
    @all_entries.each do |entry|
      entry_id = entry[0]
      entry_sentiment = (get_sentiment entry[3]).to_s
      @db.execute "UPDATE tweet_texts SET sentiment = ? WHERE ID=#{entry_id}", entry_sentiment
    end
  end

  def make_sentiment_hash(politician, feed, algorithm)
    sentiments = @all_entries.select { |entry| entry[1] == TWITTER_FEEDS[feed] && politician.include?(entry[2]) }
    freq = sentiments.inject(Hash.new(0)) { |h, v| h[v[5]] += 1;h }
  end
end