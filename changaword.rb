# frozen_string_literal: true

require 'wordnik'

class WordQuery
  def initialize
    config
  end

  def config
    Wordnik.configure do |c|
      c.api_key = 'b402d13d558a02ffe80040588900a1f0109180b15d103ea11'
      c.response_format = 'json'
      c.logger = Logger.new('/dev/null')
    end
  end

  def retrieve(word)
    resp = Wordnik.words.search_words(query: word, max_length: word.length)
    resp.map { |r| r['wordstring'] }
  end
end

def solve(wq, word_list, goal_word, num_steps)
  return nil if word_list.length > num_steps + 1
  curr_word = word_list.last
  return word_list if goal_word == curr_word
  puts "****#{num_steps} #{curr_word}"
  puts word_list.inspect
  (0..curr_word.length - 1).each do |n|
    chs =  curr_word.chars
    chs[n] = '?'
    search_term = chs.join
    puts '**' + search_term
    puts 'RESPONSE ' + wq.retrieve(search_term).inspect
    wq.retrieve(search_term).each do |next_word|
      next if word_list.include?(next_word)
      puts next_word
      new_list = word_list + [next_word]
      puts 'NEW LIST ' + new_list.inspect
      resp = solve(wq, new_list, goal_word, num_steps)
      puts 'COMING BACK ' + resp.inspect
      return resp unless resp.nil?
    end
  end
  nil
end

wq = WordQuery.new
puts solve(wq, ['sink'], 'ring', 2).inspect
