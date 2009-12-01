# This class loads a dictionary of codes with associated names, it then can
# find those names in a string of text. It works word-wise.
class DictionaryNER

  A_INT   = "a"[0]
  DOWNCASE_OFFSET = "A"[0] - "a"[0]

  require 'rbbt/bow/bow'
  # Divides a string of text into words. A slash separates words, only if the
  # second one begins with a letter.
  def self.chunk(text)
    text.split(/(?:[\s.,]|-(?=[a-zA-Z]))+/)
  end

  # Simplify the text to widen the matches. Currently only downcases the keys
  def self.simplify(text)
    if text.length > 2 && text[0] < A_INT && text[1] > A_INT
      text = (text[0] - DOWNCASE_OFFSET).chr + text[1..-1] 
    else
      return text
    end
  end

  # Given a dictionary structure, find the matches in the text.
  def self.match(dict, text) #:nodoc:

    if Array === text
      words = text
    else
      words = chunk(text) 
    end

    result = {}
    words.each_with_index{|word, pos|
      key = simplify(word)
      next if dict[key].nil?
      dict[key].each{|entrie|
        case
        when String === entrie
          result[word] ||= []
          result[word] << entrie unless result[word].include? entrie
        when Hash === entrie
          rec_words  = words[(pos + 1)..-1]
          rec_result = match(entrie, rec_words)
          rec_result.each{|rec_key, rec_list|
            composite_key = word + ' ' + rec_key
            result[composite_key] ||= []
            result[composite_key] += rec_list
            result[composite_key].uniq!
          }
        end
      }
    }
    result
  end

  # Add a name to a structure
  def self.add_name(dict, name, code)
    if Array === name
      words = name
    else
      words = chunk(name) 
    end

    key = simplify(words.shift)
    if words.empty?
      dict[key] ||= []
      dict[key] << code unless dict[key].include? code
    else
      rec_dict = {}
      add_name(rec_dict, words , code)
      dict[key] ||= []
      dict[key] << rec_dict
    end
  end

  def self.load(dictionary)
    dict = {}

    dictionary = File.open(dictionary).read if File.exists? dictionary

    dictionary.each_line{|l|
      names = l.chomp.split(/\t/)
      code  = names.shift
      names.each{|name| add_name(dict, name, code) }
    }
    dict
  end

  def initialize(dictionary)
    @dict = DictionaryNER.load(dictionary)
  end

  def match(text)
    DictionaryNER.match(@dict, text)
  end

end
