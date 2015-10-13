class Davies < SentimentAnalysis
  def initialize(database)
    super(database)
  end

  def read_sentiment_list(file_name)
    File.open(file_name) do |file|
      @happy_log_probs = {}
      @sad_log_probs = {}
      first_line = file.gets
      tokens = []
      while (line = file.gets)
        line = line.split(',')
        tokens << line[0] 
        @happy_log_probs[line[0]] = line[1]
        @sad_log_probs[line[0]] = line[2]
      end
    end
    return @happy_log_probs, @sad_log_probs
  end

  def classify_sentiment(words, happy_log_probs, sad_log_probs)
    happy_probs = {}
    sad_probs = {}
    words.each do |word|
      happy_probs[word] = happy_log_probs[word]
      sad_probs[word] = sad_log_probs[word]
    end
    total_happy_probs = happy_probs.inject(0) { |sum, (key, value)| sum + value.to_f }
    total_sad_probs = sad_probs.inject(0) { |sum, (key, value)| sum + value.to_f }
    prob_happy = 1.0 / (Math.exp(total_sad_probs - total_happy_probs) + 1)
    prob_sad = 1 - prob_happy
    return prob_happy, prob_sad
  end  

  def update_database
    @all_entries.each do |entry|
      entry_id = entry[0]
      happy_log_probs, sad_log_probs = read_sentiment_list('dictionaries/twitter_sentiment_list.csv')
      prob_happy = (classify_sentiment(entry[3].split(' '), happy_log_probs, sad_log_probs))[0]
      prob_sad = (classify_sentiment(entry[3].split(' '), happy_log_probs, sad_log_probs))[1]
      @db.execute "UPDATE tweet_texts SET davies_happy = ? WHERE ID=#{entry_id}", prob_happy
      @db.execute "UPDATE tweet_texts SET davies_sad = ? WHERE ID=#{entry_id}", prob_sad
    end
  end

  def make_sentiment_hash(politician, feed, algorithm)
    sentiments = @all_entries.select { |entry| entry[1] == TWITTER_FEEDS[feed] && politician.include?(entry[2]) }
    freq = Hash.new(0)
    freq["happy"] = 0
    freq["sad"] = 0
    sentiments.each do |entry|
      happy_prob = entry[6]
      sad_prob = entry[7]
      freq["happy"] += happy_prob.to_f
      freq["sad"] += sad_prob.to_f
    end
    freq["happy"] = freq["happy"]/sentiments.count*100
    freq["sad"] = freq["sad"]/sentiments.count*100
    return freq
  end
end