require 'rbbt'
require 'rbbt/util/simpleDSL'
require 'rbbt/util/misc'
require 'set'


class Tokenizer < SimpleDSL
  #{{{ Classes for Comparisons
  
  @@ignore_case = true

  def self.ignore_case(ignore = nil)
    if ignore.nil?
      return @@ignore_case
    else
      @@ignore_case = ignore
    end
  end
  

  class Operation

    def initialize(comparison)
      @comparison = comparison
      @ignore_case = Tokenizer::ignore_case
    end

    def ignore_case(ignore = true)
      @ignore_case = ignore
      self
    end

    def method_missing(name, *args, &bloc)
      @token = name.to_sym
      @value = *args.first
      self
    end

    def eval(list1, list2)
      toks1 = list1.select{|p| p[1] == @token}.collect{|t| @ignore_case ? t[0].to_s.downcase : t[0].to_s}
      toks2 = list2.select{|p| p[1] == @token}.collect{|t| @ignore_case ? t[0].to_s.downcase : t[0].to_s}

      value = 0
      case @comparison.to_s
      when 'same':
        if toks1 == toks2 && toks1.any?
          value = @value
        end
      when 'diff':
        if toks1 != toks2
          value = @value
        end
      when 'common':
        if toks1.to_set.intersection(toks2.to_set).length > 0
          value = @value
        end
      when 'distinct':
        if toks1.to_set.intersection(toks2.to_set).length == 0
          value = @value
        end
      when 'miss':
        missing = (toks1 - toks2)
        if missing.length > 0
          value = @value * missing.length
        end
      when 'extr':
        extr = (toks2 - toks1)
        if extr.length > 0
          value = @value * extr.length
        end
      end

      return value
    end
  end

  class Custom
    def initialize
      @ignore_case = Tokenizer::ignore_case
    end

    def ignore_case(ignore = true)
      @ignore_case = ignore
      self
    end

    def method_missing(name, *args, &block)
      @token = name.to_sym
      @block = block
    end

    def eval(list1, list2)
      toks1 = list1.select{|t| t[1] == @token}.collect{|t| @ignore_case ? t[0].to_s.downcase : t[0].to_s}
      toks2 = list2.select{|t| t[1] == @token}.collect{|t| @ignore_case ? t[0].to_s.downcase : t[0].to_s}

      @block.call(toks1, toks2)
    end
  end

  class Transform
    def initialize
    end
    def method_missing(name, *args, &block)
      @token = name.to_sym
      if block_given?
        @block = block
      else
        @block = args.first
      end
      self
    end

    def transform(token)
      if token[1] == @token
        token = @block.call(token[0]) 
      else
        token
      end
    end
  end


  #{{{ Metaprogramming hooks
  def define_tokens(name, *args, &block)
    action = *args[0] || block ||  /#{name.to_s}s?/i
      raise "Wrong format" unless (action.is_a?(Proc) || action.is_a?(Regexp))

    @types[name.to_sym] = action
    @order.push name.to_sym

    name.to_sym
  end

  def define_comparisons(name, *args, &block)
     o = nil
    case name.to_sym
    when :compare
      o = Custom.new
      @operations << o
    when :transform
      o = Transform.new
      @transforms << o
    else
      o = Operation.new(name)
      @operations << o
    end
    o
  end

  def main(name, *args, &block)
    parse("define_" + name.to_s,block)
  end

  #{{{ Initialize
  def initialize(file=nil, &block)
    @types = {}
    @order = []
    @operations = []
    @transforms = []

    file ||= File.join(Rbbt.datadir,'norm/config/tokens_default.rb') if !file && !block
    super(:main, file, &block)
  end


  #{{{ Token Types
  GREEK_RE = "(?:" + $greek.keys.select{|w| w.length > 3}.collect{|w| w.downcase}.join("|") + ")"
  def tokenize(word)
    return word.
      gsub(/([^IVX])I$/,'\1|I|').     # Separate last roman number
      gsub(/(\d+[,.]?\d+|\d+)/,'|\1|').     # Separate number
      gsub(/([a-z])([A-Z])/,'\1-\2').
      gsub(/([A-Z]{2,})([a-z])/,'\1-\2').
      gsub(/^(#{GREEK_RE})/,'\1-').
      gsub(/(#{GREEK_RE})$/,'-\1').
      split( /[^\w.]+/).  # Split by separator char
      select{|t|  !t.empty? }
  end


  def type(token)
    @order.each{|type|
      action = @types[type]
      if action.is_a? Proc
        return type if action.call(token)
      else
        return type if action.match(token)
      end
    }
    return :unknown
  end

  def token_types(word)
    tokenize(word).collect{|token|
      [token, type(token)]
    }
  end

  #{{{ Comparisons

  def evaluate_tokens(list1, list2)
    @operations.inject(0){| acc, o|
      acc + o.eval(list1, list2)
    }
  end

  def evaluate(mention, name)
    mention_tokens, name_tokens = [mention, name].collect{|n|
      token_types(n).collect{|t| 
        @transforms.inject(t){|t,o| 
          t = o.transform(t)
        } 
      }
    }
    evaluate_tokens(mention_tokens, name_tokens)
  end
end
