require 'sqlite3'
require 'gruff'
require_relative 'collection.rb'

class SentimentAnalysis
  def initialize(database)
    @db = SQLite3::Database.new database
    @all_entries = @db.execute "SELECT * FROM tweet_texts"
  end

  def make_sentiment_hash(politician, feed, algorithm)
    sentiments = @all_entries.select { |entry| entry[1] == TWITTER_FEEDS[feed] && politician.include?(entry[2]) }
    if algorithm == "sentimental"
      freq = sentiments.inject(Hash.new(0)) { |h, v| h[v[5]] += 1;h }
    elsif algorithm == "davies"
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
    elsif algorithm == "alchemy"
      freq = sentiments.inject(Hash.new(0)) { |h, v| h[v[8]] += 1;h }
    end
  end

  def make_chart
    update_database
    POLITICIANS.each do |politician|
      politician[0].each do |pol|
        TWITTER_FEEDS.each do |feed|
          sentiments = make_sentiment_hash("#{politician[0]}", "#{feed[0]}", @algorithm)
          g = Gruff::Pie.new
          g.font = "/Library/Fonts/Arial.ttf"
          g.title = "Sentiment from #{feed[1]}: #{politician[1]}"
          g.data 'Negative', sentiments['negative']
          g.data 'Neutral', sentiments['neutral']
          g.data 'Positive', sentiments['positive']
          g.write("img/sentimental/#{politician[1]} #{feed[0]} #{@algorithm}.png")
        end
      end
    end
  end
end

class Sentimental < SentimentAnalysis
  def initialize(database)
    super(database)
    @dictionary = {}
    @algorithm = "sentimental"
    file = File.new('dictionaries/dictionary.txt')
    while(line = file.gets)
      parsed_line = line.chomp.split(' ')
      score = parsed_line[0]
      word = parsed_line[1]
      @dictionary[word] = score.to_f
    end
    file.close
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
end

class DaviesSentimentAnalysis < SentimentAnalysis
  def initialize

  end

  def read_sentiment_list(file_name)
    file = File.new(file_name) #do ...
    happy_log_probs = {}
    sad_log_probs = {}
    first_line = file.gets
    tokens = []
    while (line = file.gets)
      line = line.split(',')
      tokens << line[0] 
      happy_log_probs[line[0]] = line[1]
      sad_log_probs[line[0]] = line[2]
    end
    return happy_log_probs, sad_log_probs
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
      @db.execute "UPDATE tweet_texts SET davies_sentiment = ? WHERE ID=#{entry_id}", prob_happy
      @db.execute "UPDATE tweet_texts SET davies_sentiment_sad = ? WHERE ID=#{entry_id}", prob_sad
    end
  end
end
