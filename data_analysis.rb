require 'sqlite3'

@db = SQLite3::Database.new "collection.sqlite3"

all_entries = @db.execute "SELECT * FROM trump_clinton_collection"

@valid_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE (mood = \"happy\") OR (mood = \"sad\") OR (mood = \"disgusted\") OR (mood = \"surprised\") OR (mood = \"neutral\") OR (mood = \"scared\") OR (mood = \"angry\")"

def analyze_moods(politician, twitter_feed)
  if twitter_feed == "breitbart"
    formal_feed_name = "Breitbart News"
  elsif twitter_feed == "cbs"
    formal_feed_name = "CBS Politics"
  elsif twitter_feed == "cnn"
    formal_feed_name = "CNN Politics"
  elsif twitter_feed == "huffpo"
    formal_feed_name = "Huffington Post Politics"
  elsif twitter_feed == "politico"
    formal_feed_name = "Politico"
  end

  if politician == "clinton"
    politician_names = ["Clinton", "Hillary", "@HillaryClinton"] 
  elsif politician == "trump"
    politician_names = ["Trump", "@realDonaldTrump"]
  end

  moods = @valid_entries.select { |entry| entry[1] == formal_feed_name && politician_names.include?(entry[3]) }

  freq = moods.inject(Hash.new(0)) { |h, v| h[v[6]] += 1;h }
  puts "#{politician}'s breakdown from #{formal_feed_name} is:"
  puts "#{freq}"

  #dominant_mood = freq.max_by{ |k, v| v }[0]
end

puts ""
analyze_moods('clinton', 'breitbart')
analyze_moods('trump', 'breitbart')
puts ""

analyze_moods('clinton', 'cbs')
analyze_moods('trump', 'cbs')
puts ""

analyze_moods('clinton', 'cnn')
analyze_moods('trump', 'cnn')
puts ""

analyze_moods('clinton', 'huffpo')
analyze_moods('trump', 'huffpo')
puts ""

analyze_moods('clinton', 'politico')
analyze_moods('trump', 'politico')
puts ""
