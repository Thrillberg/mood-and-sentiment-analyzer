## README

### More Than Meets The Eye:
#### Using mood and sentiment detection to analyze how different news outlets portray politicians

collection.rb - This project uses the Twitter gem to collect tweets from five news outlets (Breitbart News, CBS Politics, CNN Politics, Huffington Post Politics, and Politico) that mention either of two politicians (Donald Trump and Hillary Clinton). Then it uses the Mechanize gem to parse through the tweets and extract URLs for images.

face_analysis.rb - Using the SkyBiometry API, the app then analyzes the images for faces and detects moods for each face.

sentiment_collection.rb - Using the Sentimental gem, the app analyzes the text of the tweets for sentiment.

mood_and_sentiment_analysis.rb - Finally, the app uses the Gruff gem to create charts for each news outlet/politician combination, one with respect to mood and one with respect to sentiment.