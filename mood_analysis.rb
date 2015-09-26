require 'sqlite3'
require 'face'
require 'dotenv'

Dotenv.load "application.env"
@db = SQLite3::Database.new "collection.sqlite3"
client = Face.get_client(:api_key => ENV["FACE_KEY"], :api_secret => ENV["FACE_SECRET"])

# politicians = {
#   'clinton': ['@HillaryClinton', 'Clinton', 'Hillary'],
#   'trump': ['@realDonaldTrump', 'Trump']
# }

# news_outlets = {
#   'CNN Politics': 'cnn',
#   'Huffington Post Politics': 'huffpo',
#   'CBS Politics': 'cbs',
#   'Breitbart News': 'breitbart',
#   'Politico': 'politico'
# }

# news_outlets.each do |news_key, news_value|
#   politicians.each do |pol_key, pol_value|
#     get_entries = "#{news_value}_#{pol_key}_entries = @db.execute 'SELECT * FROM trump_clinton_collection WHERE twitter_account = '#{news_key}' AND (politician = '#{pol_value[0]}' OR politician = '#{pol_value[1]}')'"
#     eval(get_entries)
#   end
# end

# cnn_trump_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'CNN Politics' AND (politician = 'Trump' OR politician = '@realDonaldTrump')"

# cnn_clinton_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'CNN Politics' AND (politician = 'Clinton' OR politician = 'Hillary' OR politician = '@HillaryClinton')"

# huffpo_trump_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'Huffington Post Politics' AND (politician = 'Trump' OR politician = '@realDonaldTrump')"

# huffpo_clinton_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'Huffington Post Politics' AND (politician = 'Clinton' OR politician = 'Hillary' OR politician = '@HillaryClinton')"

# cbs_trump_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'CBS Politics' AND (politician = 'Trump' OR politician = '@realDonaldTrump')"

# cbs_clinton_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'CBS Politics' AND (politician = 'Clinton' OR politician = 'Hillary' OR politician = '@HillaryClinton')"

# breitbart_trump_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'Breitbart News' AND (politician = 'Trump' OR politician = '@realDonaldTrump')"

# breitbart_clinton_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'Breitbart News' AND (politician = 'Clinton' OR politician = 'Hillary' OR politician = '@HillaryClinton')"

# politico_trump_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'Politico' AND (politician = 'Trump' OR politician = '@realDonaldTrump')"

# politico_clinton_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE twitter_account = 'Politico' AND (politician = 'Clinton' OR politician = 'Hillary' OR politician = '@HillaryClinton')"

all_entries = @db.execute "SELECT * FROM trump_clinton_collection"

remaining_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE (mood IS NULL)"

error_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE (mood = \"ERROR\")"

clinton_breitbart_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"Breitbart News\" AND politician = \"Clinton\" OR \"Hillary\" OR \"@HillaryClinton\")")
clean_clinton_breitbart_moods = clinton_breitbart_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_clinton_breitbart_moods = clean_clinton_breitbart_moods.reject { |mood| mood[0] == "ERROR" }
clinton_breitbart_dominant_mood = Hash.new(0)
clean_clinton_breitbart_moods.each { |v| clinton_breitbart_dominant_mood.store(v, clinton_breitbart_dominant_mood[v]+1) }
clinton_breitbart_dominant_mood = clinton_breitbart_dominant_mood.max_by{ |k, v| v }[0][0]

trump_breitbart_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"Breitbart News\" AND politician = \"Trump\" OR \"@realDonaldTrump\")")
clean_trump_breitbart_moods = trump_breitbart_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_trump_breitbart_moods = clean_trump_breitbart_moods.reject { |mood| mood[0] == "ERROR" }
trump_breitbart_dominant_mood = Hash.new(0)
clean_trump_breitbart_moods.each { |v| trump_breitbart_dominant_mood.store(v, trump_breitbart_dominant_mood[v]+1) }
trump_breitbart_dominant_mood = trump_breitbart_dominant_mood.max_by{ |k, v| v }[0][0]



clinton_cbs_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"CBS Politics\" AND politician = \"Clinton\" OR \"Hillary\" OR \"@HillaryClinton\")")
clean_clinton_cbs_moods = clinton_cbs_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_clinton_cbs_moods = clean_clinton_cbs_moods.reject { |mood| mood[0] == "ERROR" }
clinton_cbs_dominant_mood = Hash.new(0)
clean_clinton_cbs_moods.each { |v| clinton_cbs_dominant_mood.store(v, clinton_cbs_dominant_mood[v]+1) }
clinton_cbs_dominant_mood = clinton_cbs_dominant_mood.max_by{ |k, v| v }[0][0]

trump_cbs_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"CBS Politics\" AND politician = \"Trump\" OR \"@realDonaldTrump\")")
clean_trump_cbs_moods = trump_cbs_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_trump_cbs_moods = clean_trump_cbs_moods.reject { |mood| mood[0] == "ERROR" }
trump_cbs_dominant_mood = Hash.new(0)
clean_trump_cbs_moods.each { |v| trump_cbs_dominant_mood.store(v, trump_cbs_dominant_mood[v]+1) }
trump_cbs_dominant_mood = trump_cbs_dominant_mood.max_by{ |k, v| v }[0][0]



clinton_cnn_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"CNN Politics\" AND politician = \"Clinton\" OR \"Hillary\" OR \"@HillaryClinton\")")
clean_clinton_cnn_moods = clinton_cnn_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_clinton_cnn_moods = clean_clinton_cnn_moods.reject { |mood| mood[0] == "ERROR" }
clinton_cnn_dominant_mood = Hash.new(0)
clean_clinton_cnn_moods.each { |v| clinton_cnn_dominant_mood.store(v, clinton_cnn_dominant_mood[v]+1) }
clinton_cnn_dominant_mood = clinton_cnn_dominant_mood.max_by{ |k, v| v }[0][0]

trump_cnn_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"CNN Politics\" AND politician = \"Trump\" OR \"@realDonaldTrump\")")
clean_trump_cnn_moods = trump_cnn_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_trump_cnn_moods = clean_trump_cnn_moods.reject { |mood| mood[0] == "ERROR" }
trump_cnn_dominant_mood = Hash.new(0)
clean_trump_cnn_moods.each { |v| trump_cnn_dominant_mood.store(v, trump_cnn_dominant_mood[v]+1) }
trump_cnn_dominant_mood = trump_cnn_dominant_mood.max_by{ |k, v| v }[0][0]



clinton_huffpo_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"Huffington Post Politics\" AND politician = \"Clinton\" OR \"Hillary\" OR \"@HillaryClinton\")")
clean_clinton_huffpo_moods = clinton_huffpo_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_clinton_huffpo_moods = clean_clinton_huffpo_moods.reject { |mood| mood[0] == "ERROR" }
clinton_huffpo_dominant_mood = Hash.new(0)
clean_clinton_huffpo_moods.each { |v| clinton_huffpo_dominant_mood.store(v, clinton_huffpo_dominant_mood[v]+1) }
clinton_huffpo_dominant_mood = clinton_huffpo_dominant_mood.max_by{ |k, v| v }[0][0]

trump_huffpo_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"Huffington Post Politics\" AND politician = \"Trump\" OR \"@realDonaldTrump\")")
clean_trump_huffpo_moods = trump_huffpo_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_trump_huffpo_moods = clean_trump_huffpo_moods.reject { |mood| mood[0] == "ERROR" }
trump_huffpo_dominant_mood = Hash.new(0)
clean_trump_huffpo_moods.each { |v| trump_huffpo_dominant_mood.store(v, trump_huffpo_dominant_mood[v]+1) }
trump_huffpo_dominant_mood = trump_huffpo_dominant_mood.max_by{ |k, v| v }[0][0]



clinton_politico_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"Politico\" AND politician = \"Clinton\" OR \"Hillary\" OR \"@HillaryClinton\")")
clean_clinton_politico_moods = clinton_politico_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_clinton_politico_moods = clean_clinton_politico_moods.reject { |mood| mood[0] == "ERROR" }
clinton_politico_dominant_mood = Hash.new(0)
clean_clinton_politico_moods.each { |v| clinton_politico_dominant_mood.store(v, clinton_politico_dominant_mood[v]+1) }
clinton_politico_dominant_mood = clinton_politico_dominant_mood.max_by{ |k, v| v }[0][0]

trump_politico_moods = @db.execute("SELECT mood FROM trump_clinton_collection WHERE (twitter_account = \"Politico\" AND politician = \"Trump\" OR \"@realDonaldTrump\")")
clean_trump_politico_moods = trump_politico_moods.reject { |mood| mood[0] == "MULTIPLE FACES" }
clean_trump_politico_moods = clean_trump_politico_moods.reject { |mood| mood[0] == "ERROR" }
trump_politico_dominant_mood = Hash.new(0)
clean_trump_politico_moods.each { |v| trump_politico_dominant_mood.store(v, trump_politico_dominant_mood[v]+1) }
trump_politico_dominant_mood = trump_politico_dominant_mood.max_by{ |k, v| v }[0][0]

require 'pry';binding.pry

# dominant_mood_count = 0
# clinton_breitbart_moods.each do |mood|
#   if mood[0] == dominant_mood
#     dominant_mood_count += 1
#   end
# end

# require 'pry';binding.pry

# remaining_entries.each do |entry|
#   begin
#     face_data = client.faces_detect(:urls => entry[2], :attributes => 'mood')
#     if face_data["photos"][0]["tags"].count > 1
#       statement = "UPDATE trump_clinton_collection SET mood = \"MULTIPLE FACES\" WHERE id = #{entry[0]}"
#       @db.execute statement
#       next
#     end
#     mood = [face_data["photos"][0]["tags"][0]["attributes"]["mood"]["value"]][0]
#     statement = "UPDATE trump_clinton_collection SET mood = \"#{mood}\" WHERE id = #{entry[0]}"
#     @db.execute statement
#   rescue
#     statement = "UPDATE trump_clinton_collection SET mood = \"ERROR\" WHERE id = #{entry[0]}"
#     @db.execute statement
#     next
#   end
# end
