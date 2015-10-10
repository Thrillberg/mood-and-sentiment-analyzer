require 'sqlite3'
require 'gruff'

@db = SQLite3::Database.new "collection.sqlite3"

@valid_entries = @db.execute "SELECT * FROM tweet_texts"

@politicians = {"clinton" => ["Clinton", "Hillary", "@HillaryClinton"], "trump" => ["Trump", "@realDonaldTrump"]}
@twitter_feeds = {"breitbart" => "Breitbart News", "cbs" => "CBS Politics", "cnn" => "CNN Politics", "huffpo" => "Huffington Post", "politico" => "Politico"}

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

#sentiment charting
@politicians.each do |politician|
  @twitter_feeds.each do |feed|
    freq = analyze_sentiments("#{politician[0]}", "#{feed[0]}")
    g = Gruff::Pie.new
    g.font = "/Library/Fonts/Arial.ttf"
    g.title = "sentiment associated with #{politician[0]} in #{feed[0]}"
    g.data 'Sad', freq['sad']
    g.data 'Happy', freq['happy']
    g.write("img/#{politician[0]}_#{feed[0]}_davies.png")
  end
end
