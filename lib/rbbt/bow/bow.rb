require 'rbbt'
require 'stemmer'
require 'rbbt/util/misc'

# This module provides methods to extract a bag of words (or bag of bigrams)
# representation for strings of text, and to produce a vector representations
# of that bag of words for a given list of terms. This BOW representations of
# the texts is usually first used to build a Dictionary, and then, with the
# best selection of terms as determined by the Dictionary::TF_IDF.best of
# Dictionary::KL.best methods, determine the vector representations for that
# text.
module BagOfWords

  # Divide the input string into an array of words (sequences of \w characters).
  # Words are stemmed and filtered to remove stopwords and words with less than
  # 2 characters. The list of stopwords is a global variable defined in
  # 'rbbt/util/misc'.
  def self.words(text)
    return [] if text.nil?
    text.scan(/\w+/).
      collect{|word| word.downcase.stem}.
      select{|word|  
      ! $stopwords.include?(word) && 
        word.length > 2 && 
        word =~ /[a-z]/
    }
  end

  # Take the array of words for the text and form all the bigrams
  def self.bigrams(text)
    words = words(text)
    bigrams = []
    lastword = nil

    words.each{|word|
      if lastword
        bigrams << "#{lastword} #{word}"
      end
      lastword = word
    }

    words + bigrams
  end

  # Given an array of terms return a hash with the number of appearances of
  # each term
  def self.count(terms)
    count = Hash.new(0)
    terms.each{|word| count[word] += 1}
    count
  end


  # Given a string of text find all the words (or bigrams) and return a hash
  # with their counts
  def self.terms(text, bigrams = true)

    if bigrams
      count(bigrams(text))
    else
      count(words(text))
    end
  end

  # Given a string of text and a list of terms, which may or may not contain
  # bigrams, return an array with one entry per term which holds the number of
  # occurrences of each term in the text.
  def self.features(text, terms, bigrams = nil)
    bigrams ||= terms.select{|term| term =~ / /}.any?
    count = bigrams ? count(bigrams(text)) : count(words(text))
    count.values_at(*terms)
  end
end

class String
  # Shortcut for BagOfWords.words(self)
  def words
    BagOfWords.words(self)
  end

  # Shortcut for BagOfWords.bigrams(self)
  def bigrams
    BagOfWords.bigrams(self)
  end
end


