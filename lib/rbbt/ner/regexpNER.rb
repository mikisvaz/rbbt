require 'rbbt/util/open'
require 'rbbt/util/misc'

class RegExpNER

  def self.match_re(text, res)
    res = [res] unless Array === res

    res.collect{|re|
      text.scan(re) 
    }.flatten
  end

  def self.build_re_old(names, ignorecase=true)
    names.compact.select{|n| n != ""}.
      sort{|a,b| b.length <=> a.length}.
      collect{|n| 
        re = Regexp.quote(n).gsub(/\\?\s/,'\s+')
      }
  end

  def self.build_re(names, ignorecase=true)
    res = names.compact.select{|n| n != ""}.
      sort{|a,b| b.length <=> a.length}.
      collect{|n| 
        Regexp.quote(n)
      }

    /\b(#{ res.join("|").gsub(/\\?\s/,'\s+') })\b/
  end


  def initialize(lexicon, options = {})
    options = {:flatten => true, :ignorecase => true, :stopwords => nil}.merge options

    options[:stopwords] = $stopwords if $stopwords && (options[:stopwords].nil? || options[:stopwords] == true)
    options[:stopwords] ||= []

    data = Open.to_hash(lexicon, options)

    @index = {}
    data.collect{|code, names|
      next if code.nil? || code == ""
      if options[:stopwords].any?
        names = names.select{|n| 
          ! options[:stopwords].include?(options[:ignorecase] ? n.downcase : n)
        } 
      end
      @index[code] = RegExpNER.build_re(names, options[:ignorecase])
   }
  end

  def match_hash(text)
    return {} if text.nil? || text == ""
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
    match_hash(text)
  end

end

