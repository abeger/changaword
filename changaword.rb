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
      return new_list if next_word == goal_word
      next unless new_list.length <= goal_steps
      resp = solve(wq, new_list, goal_word, goal_steps, n)
      return resp unless resp.nil?
    end
  end
  nil
end

wq = WordQuery.new
answer = solve(wq, ['comp'], 'rise', 4).inspect
puts "\n\nANSWER: " + answer
