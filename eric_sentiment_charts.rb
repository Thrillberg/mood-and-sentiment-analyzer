require 'sqlite3'
require 'gruff'

@db = SQLite3::Database.new "db/collection.sqlite3"

@valid_entries = @db.execute "SELECT * FROM tweet_texts WHERE id BETWEEN 1 AND 112"

@politicians = {"clinton" => ["Clinton", "Hillary", "@HillaryClinton"], "trump" => ["Trump", "@realDonaldTrump"]}
@twitter_feeds = {"cnn" => "CNN Politics"}

def analyze_sentiments(politician, twitter_feed)
  formal_feed_name = ""
  @twitter_feeds.each do |feed|
    if twitter_feed == feed[0]
      formal_feed_name = feed[1]
    end
  end

  politician_names = []
  @politicians.each do |pol|
    if politician == pol[0]
      politician_names = pol[1]
    end
  end

  sentiments = @valid_entries.select { |entry| entry[1] == formal_feed_name && politician_names.include?(entry[2]) }
  freq = sentiments.inject(Hash.new(0)) { |h, v| h[v[9]] += 1;h }
end

#sentiment charting
@politicians.each do |politician|
  @twitter_feeds.each do |feed|
    sentiments = analyze_sentiments("#{politician[0]}", "#{feed[0]}")
    g = Gruff::Pie.new
    g.font = "/Library/Fonts/Arial.ttf"
    g.title = "sentiment associated with #{politician[0]} in #{feed[0]}"
    g.data 'Negative', sentiments['negative']
    g.data 'Neutral', sentiments['neutral']
    g.data 'Positive', sentiments['positive']
    g.write("img/eric/#{politician[0]}_#{feed[0]}_eric.png")
  end
end
