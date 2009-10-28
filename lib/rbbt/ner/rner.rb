require 'rbbt'
require 'rbbt/util/open'
require 'rbbt/util/misc'
require 'rbbt/util/simpleDSL'

class NERFeatures < SimpleDSL
  def self.tokens(text)
    text.scan(/
              \w*-?(?:\d*\d[.,]\d\d*|\d+)\w*|
              \w-\w*|
              \w+-[A-Z](?!\w)|
              \w+|
              [.,()\/\[\]{}'"+-]
              /x)
  end

  def self.reverse(text)
    tokens(text).reverse.join(" ")
  end

  def define(name, *args, &block)
    action = *args[0] || block ||  /#{name.to_s}s?/i
    raise "Wrong format" unless (action.is_a?(Proc) || action.is_a?(Regexp))

    @types[name.to_s] = action
    @order.push name.to_s

    name.to_s
  end

  attr_accessor :reverse
  def initialize(file = nil, reverse = false, &block)
    @types   = {}
    @order   = []
    @context = []
    @reverse = reverse

    file ||= File.join(Rbbt.datadir,'ner/config/default.rb') if !file && !block

    super(:define,file, &block)
  end

  def config
    @config[:define]
  end

  def window(positions)
    @window = positions
  end

  def context(name, &block)
    if name.is_a? Array
      @context += name
    else
      @context.push name

      # The block might be wrongly assigned to this function
      # instead of the actual definition, fix that.
      if block
        @types[name] = block
      end
    end
  end

  def direction(dir)
    if dir.to_sym == :reverse
      @reverse = true
    end
  end

  def features(word)
    values = [word]

    @order.each{|features|
      action = @types[features]
      if action.is_a?(Proc)
        values.push(action.call(word))
      else
        m = action.match(word)
        if m
          if m[1]
            values.push(m[1])
          else
            values.push(m != nil)
          end
        else
          values.push(false)
        end
      end
    }
    values
  end
 
  def template(window=nil)
    window ||= @window || [1,-1]
    template = ""

    i = 1
    @order.each{|feat|
      template += "U#{ feat }: %x[0,#{ i }]\n"

      if @context.include?(feat)
        window.each{|p|
          template += "U#{ feat }##{ p}: %x[#{ p },#{ i }]\n"
        }
      end
      i += 1
    }
      
    template += "B\n"

    template
  end


  def text_features(text, positive = nil)
    text = self.class.reverse(text) if @reverse
    initial = true
    self.class.tokens(text).collect{|token|
      features = features(token)
      if !positive.nil?
        features << (positive ? (initial ? 1 : 2) : 0)
        initial = false
      end
      features
    }
  end

  def tagged_features(text, mentions)
    mentions ||= []
    mentions = ['IMPOSSIBLE_MATCH'] if mentions.empty?
    re = mentions.collect{|mention|
      Regexp.quote(mention.gsub(/\s+/,' ')).sub(/\\s/,'\s+')
    }.join("|")

    positive = false
    features = []
    chunks = text.split(/(#{re})/)
    chunks.each{|t|
      chunk_features = text_features(t, positive)
      positive = !positive
      if @reverse
        features = chunk_features + features
      else
        features = features + chunk_features
      end
    }
    features
  end

  def train(features, model)
    tmp_template = TmpFile.tmp_file("template-")
    Open.write(tmp_template,template)

    cmd = "#{File.join(Rbbt.datadir, 'third_party/crf++/bin/crf_learn')} '#{tmp_template}'  '#{features}' '#{model}'"
    system cmd
    Open.write(model + '.config',config)
    FileUtils.rm tmp_template
  end

end

class NER

  def initialize(model = nil)
    begin
      require 'CRFPP'
    rescue Exception
      require File.join(Rbbt.datadir, 'third_party/crf++/ruby/CRFPP')
    end

    model ||= File.join(Rbbt.datadir, + 'ner/model/BC2')

    @parser = NERFeatures.new(model + '.config')
    @reverse = @parser.reverse
    @tagger = CRFPP::Tagger.new("-m #{ model } -v 3 -n2")
  end

  def extract(text)
    features = @parser.text_features(text)
  
    @tagger.clear
    features.each{|feats|
      @tagger.add(feats.join(" "))
    }

    @tagger.parse

    found = []
    mention = []

    @tagger.size.times{|i|
      label = @tagger.y(i)
      word  = @tagger.x(i,0)

      if word == ')' 
        mention.push(')') if mention.join =~ /\(/
        next
      end

      case label
      when 1
        if mention.any? && ( mention.join(" ").is_special? || mention.select{|m| m.is_special?}.any?)
          found.push(mention)
          mention = []
        end
        mention.push(word)
      when 2
        mention.push(word)
      when 0
        found.push(mention) if mention.any?
        mention = []
      end
    }

    found << mention if mention.any?

    found.collect{|list| 
      list = list.reverse if @reverse
      list.join(" ")
    }
  end

end



