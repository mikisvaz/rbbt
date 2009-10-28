require 'rbbt/util/open'
require 'rbbt/util/misc'

class RegExpNER

  def self.match_re(text, res)
    res = [res] unless Array === res

    res.collect{|re|
      if text.match(re)
        $1
      else
        nil
      end
    }.compact
  end

  def self.build_re(names, ignorecase=true)
    names.compact.select{|n| n != ""}.
      sort{|a,b| b.length <=> a.length}.
      collect{|n| 
        re = Regexp.quote(n).gsub(/\\?\s/,'\s+')
        /(?:^|[^\w])(#{ re })(?:$|[^\w])/i
      }
  end

  def initialize(lexicon, options = {})
    options[:flatten] = true
    options[:ignorecase] = true if options[:ignorecase].nil?
    options[:stopwords] = true if options[:stopwords].nil?

    data = Open.to_hash(lexicon, options)

    @index = {}
    data.collect{|code, names|
      next if code.nil? || code == ""
      if options[:stopwords]
        names = names.select{|n| 
          ! $stopwords.include?(options[:ignorecase] ? n.downcase : n)
        } 
      end
      @index[code] = RegExpNER.build_re(names, options[:ignorecase])
   }
  end

  def match_hash(text)
    matches = {}
    @index.each{|code, re|
      RegExpNER.match_re(text, re).each{|match|
         matches[code] ||= []
         matches[code] << match
      }
    }
    matches
  end

  def match(text)
    match_hash(text).values.flatten
  end

end

