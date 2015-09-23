require 'rss'
require 'open-uri'
require 'sqlite3'

@db = SQLite3::Database.new "collection.sqlite3"

def populate_database(url, publisher)
  open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  subjects = ["Clinton", "Trump", "Fiorina", "Jeb Bush", "Sanders"]

    feed.items.each do |item|
      subjects.each do |subject|
        begin
          if item.title.downcase.split(' ').include?(subject.downcase) || item.description.gsub!(/\n/, '').gsub!(/\"/, '').downcase.split(' ').include?(subject.downcase)
            statement = "INSERT INTO collection (publisher, title, link, description, date) VALUES (\"#{publisher}\", \"#{item.title}\", \"#{item.link}\", \"#{item.description}\", \"#{item.pubDate}\")"
            @db.execute statement
          end
        rescue
          next
        end
      end
    end
  end
end

populate_database('http://www.weeklystandard.com/rss/site.xml', 'Weekly Standard')

populate_database('http://blogs.wsj.com/washwire/feed/', 'Wall Street Journal Washington Wire')

populate_database('http://rss.nytimes.com/services/xml/rss/nyt/Politics.xml', 'New York Times')

populate_database('http://time.com/politics/feed/', 'Time')

populate_database('http://feeds.slate.com/slate-101526', 'Slate')
