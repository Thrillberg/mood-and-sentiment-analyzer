def read_sentiment_list(file_name)
  file = File.new(file_name)
  happy_log_probs = {}
  sad_log_probs = {}
  first_line = file.gets
  tokens = []
  while (line = file.gets)
    line = line.split(',')
    tokens << line[0] 
    happy_log_probs[line[0]] = line[1]
    sad_log_probs[line[0]] = line[2]
  end
  return happy_log_probs, sad_log_probs
end

def classify_sentiment(words, happy_log_probs, sad_log_probs)
  happy_probs = {}
  sad_probs = {}
  words.each do |word|
    happy_probs[word] = happy_log_probs[word]
    sad_probs[word] = sad_log_probs[word]
  end
  total_happy_probs = happy_probs.inject(0) { |sum, (key, value)| sum + value.to_f }
  total_sad_probs = sad_probs.inject(0) { |sum, (key, value)| sum + value.to_f }
  prob_happy = 1.0 / (Math.exp(total_sad_probs - total_happy_probs) + 1)
  prob_sad = 1 - prob_happy
  return prob_happy, prob_sad
end
