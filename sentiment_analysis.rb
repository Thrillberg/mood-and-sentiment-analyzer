require 'sqlite3'
require 'gruff'
require_relative 'collection.rb'
# require_relative 'sentimental.rb'
# require_relative 'davies.rb'
# require_relative 'alchemy.rb'

class SentimentAnalysis
  def initialize(database)
    @db = SQLite3::Database.new database
    @all_entries = @db.execute "SELECT * FROM tweet_texts"
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