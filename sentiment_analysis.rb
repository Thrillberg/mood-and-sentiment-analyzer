DICTIONARY = {}
@threshold = 0.0

file = File.new('dictionaries/dictionary.txt')
while (line = file.gets)
  parsed_line = line.chomp.split(' ')
  score = parsed_line[0]
  word = parsed_line[1]
  DICTIONARY[word] = score.to_f
end
file.close

def get_score(string)
  sentiment_total = 0.0
  tokens = string.to_s.downcase.split(' ')

  tokens.each do |token|
    begin
      sentiment_total += DICTIONARY[token]
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
