# frozen_string_literal: true

require 'wordnik'

class WordQuery
  def initialize(api_key)
    @api_key = api_key
    @freq_list = {}
    config
  end

  def config
    Wordnik.configure do |c|
      c.api_key = @api_key
      c.response_format = 'json'
      c.logger = Logger.new('/dev/null')
    end
  end

  def retrieve(word)
    resp = Wordnik.words.search_words(query: word, max_length: word.length)
    words = resp.map { |r| r['wordstring'] }
    words.select do |w|
      /^[a-z]+$/ =~ w && freq(w) >= 20
    end
  end

  def freq(word)
    unless @freq_list.key?(word)
      resp = Wordnik.word.get_word_frequency(word, start_year: 1950)
      @freq_list[word] = resp['totalCount']
    end
    @freq_list[word]
  end
end

class Changaword
  def initialize(word_query)
    @word_query = word_query
  end

  def solve(word_list, goal_word, goal_steps, prev_n = nil)
    curr_word = word_list.last
    if word_list.size == goal_steps - (goal_word.length - (goal_word.length - 2))
      return nil unless diff(curr_word, goal_word) == (goal_word.length - 1)
    end
    if word_list.size == goal_steps - (goal_word.length - (goal_word.length - 1))
      return nil unless diff(curr_word, goal_word) == (goal_word.length - 2)
    end
    if word_list.size == goal_steps - (goal_word.length - goal_word.length)
      return nil unless diff(curr_word, goal_word) == (goal_word.length - 3)
      return word_list + [goal_word]
    end
    (0..curr_word.length - 1).each do |n|
      next if n == prev_n
      chs =  curr_word.chars
      chs[n] = '?'
      search_term = chs.join
      @word_query.retrieve(search_term).each do |next_word|
        next if word_list.include?(next_word)
        new_list = word_list + [next_word]
        puts new_list.inspect
        resp = solve(new_list, goal_word, goal_steps, n)
        return resp unless resp.nil?
      end
    end
    nil
  end

  def diff(word1, word2)
    s = word1.chars.each_with_index.reject do |c, i|
      word2[i] == c
    end.size
    puts "** #{word1} <=> #{word2}: #{s}"
    s
  end
end

def api_key
  File.open('key.txt', 'r') do |f|
    return f.read.strip
  end
end

c = Changaword.new(WordQuery.new(api_key))
answer = c.solve(['seat'], 'rain', 6).inspect
puts "\n\nANSWER: " + answer
