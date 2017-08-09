# frozen_string_literal: true

require 'wordnik'

class WordQuery
  def initialize
    config
    @freq_list = {}
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
    words = resp.map { |r| r['wordstring'] }
    words.select do |w|
      freq(w) >= 20
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
    if word_list.size == goal_steps
      return nil unless one_away?(curr_word, goal_word)
      return word_list + [goal_word]
    end
    (0..curr_word.length - 1).each do |n|
      next if n == prev_n
      chs =  curr_word.chars
      chs[n] = '?'
      search_term = chs.join
      @word_query.retrieve(search_term).each do |next_word|
        next if word_list.include?(next_word)
        next if /[A-Z]/ =~ next_word
        new_list = word_list + [next_word]
        puts new_list.inspect
        resp = solve(new_list, goal_word, goal_steps, n)
        return resp unless resp.nil?
      end
    end
    nil
  end

  def one_away?(word1, word2)
    diff(word1, word2) == 1
  end

  def diff(word1, word2)
    word1.chars.each_with_index.reject do |c, i|
      word2[i] == c
    end.size
  end
end

c = Changaword.new(WordQuery.new)
answer = c.solve(['said'], 'land', 2).inspect
puts "\n\nANSWER: " + answer
