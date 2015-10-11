require 'sqlite3'
require 'face'
require 'dotenv'

Dotenv.load "application.env"
@db = SQLite3::Database.new "db/collection.sqlite3"
client = Face.get_client(:api_key => ENV["FACE_KEY"], :api_secret => ENV["FACE_SECRET"])

all_entries = @db.execute "SELECT * FROM trump_clinton_collection"

remaining_entries = @db.execute "SELECT * FROM trump_clinton_collection WHERE (mood IS NULL)"

remaining_entries.each do |entry|
  begin
    face_data = client.faces_detect(:urls => entry[2], :attributes => 'mood')
    if face_data["photos"][0]["tags"].count > 1
      statement = "UPDATE trump_clinton_collection SET mood = \"MULTIPLE FACES\" WHERE id = #{entry[0]}"
      @db.execute statement
      next
    end
    mood = [face_data["photos"][0]["tags"][0]["attributes"]["mood"]["value"]][0]
    statement = "UPDATE trump_clinton_collection SET mood = \"#{mood}\" WHERE id = #{entry[0]}"
    @db.execute statement
  rescue
    statement = "UPDATE trump_clinton_collection SET mood = \"ERROR\" WHERE id = #{entry[0]}"
    @db.execute statement
    next
  end
end
