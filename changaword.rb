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

def solve(wq, word_list, goal_word, goal_steps, prev_n = nil)
  curr_word = word_list.last
  return word_list + [goal_word] if one_away?(curr_word, goal_word)
  (0..curr_word.length - 1).each do |n|
    next if n == prev_n
    chs =  curr_word.chars
    chs[n] = '?'
    search_term = chs.join
    wq.retrieve(search_term).each do |next_word|
      next if word_list.include?(next_word)
      next if /[A-Z]/ =~ next_word
      new_list = word_list + [next_word]
      puts new_list.inspect
      next unless new_list.length <= goal_steps
      resp = solve(wq, new_list, goal_word, goal_steps, n)
      return resp unless resp.nil?
    end
  end
  nil
end

def one_away?(word1, word2)
  word1.chars.reject do |c|
    word2.include?(c)
  end.size == 1
end

wq = WordQuery.new
answer = solve(wq, ['buck'], 'ling', 4).inspect
puts "\n\nANSWER: " + answer
