require 'sqlite3'
require 'gruff'

@db = SQLite3::Database.new "db/collection.sqlite3"
@valid_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE (mood = \"happy\") OR (mood = \"sad\") OR (mood = \"disgusted\") OR (mood = \"surprised\") OR (mood = \"neutral\") OR (mood = \"scared\") OR (mood = \"angry\")"

@politicians = {"clinton" => ["Clinton", "Hillary", "@HillaryClinton"], "trump" => ["Trump", "@realDonaldTrump"]}
@twitter_feeds = {"breitbart" => "Breitbart News", "cbs" => "CBS Politics", "cnn" => "CNN Politics", "huffpo" => "Huffington Post Politics", "politico" => "Politico"}

def analyze_moods(politician, twitter_feed)
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

  moods = @valid_entries.select { |entry| entry[1] == formal_feed_name && politician_names.include?(entry[3]) }
  freq = moods.inject(Hash.new(0)) { |h, v| h[v[6]] += 1;h }
end

# mood charting
@politicians.each do |politician|
  @twitter_feeds.each do |feed|
    moods = analyze_moods("#{politician[0]}", "#{feed[0]}")
    g = Gruff::Pie.new
    g.font = "/Library/Fonts/Arial.ttf"
    g.title = "#{feed[0]}'s representation of #{politician[0]}'s mood"
    g.data 'Scared', moods['scared']
    g.data 'Happy', moods['happy']
    g.data 'Angry', moods['angry']
    g.data 'Sad', moods['sad']
    g.data 'Surprised', moods['surprised']
    g.data 'Neutral', moods['neutral']
    g.data 'Disgusted', moods['disgusted']
    g.write("img/#{politician[0]}_#{feed[0]}_moods.png")
  end
end
