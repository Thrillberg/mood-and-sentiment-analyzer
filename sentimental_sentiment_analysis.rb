class SentimentalSentimentAnalysis
  def initialize(database)
    DICTIONARY = {}
    file = File.new('dictionaries/dictionary.txt')
    while (line = file.gets)
      parsed_line = line.chomp.split(' ')
      score = parsed_line[0]
      word = parsed_line[1]
      DICTIONARY[word] = score.to_f
    end
    file.close

    @db = SQLite3::Database.new database
    @all_entries = @db.execute "SELECT * FROM tweet_texts"
  end

  def get_score(string)
    sentiment_total = 0.0
    tokens = string.to_s.downcase.split(' ')

    tokens.each do |token|
      begin
        sentiment_total += DICTIONARY[token]
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

  def make_chart
    @politicians.each do |politician|
      @twitter_feeds.each do |feed|
        sentiments = analyze_sentiments("#{politician[0]}", "#{feed[0]}")
        g = Gruff::Pie.new
        g.font = "/Library/Fonts/Arial.ttf"
        g.title = "sentiment associated with #{politician[0]} in #{feed[0]}"
        g.data 'Negative', sentiments['negative']
        g.data 'Neutral', sentiments['neutral']
        g.data 'Positive', sentiments['positive']
        g.write("img/sentimental/#{politician[0]}_#{feed[0]}_sentimental.png")
      end
    end
  end

  def update_database
    @all_entries.each do |entry|
      entry_id = entry[0]
      entry_sentiment = (get_sentiment entry[3]).to_s
      @db.execute "UPDATE tweet_texts SET sentiment = ? WHERE ID=#{entry_id}", entry_sentiment
    end
  end
end
