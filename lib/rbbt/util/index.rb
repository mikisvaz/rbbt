require 'rbbt/util/open'
require 'rbbt/util/arrayHash'

module Index

  # Creates an inverse index. Takes a file with rows of elements
  # separated by a given pattern (specified by +sep+) and returns a hash
  # where each element points to the first element in the row. +lexicon+
  # is the file containing the data.
  def self.index(lexicon, options = {}) 
    options = {:sep => "\t|\\|", :case_sensitive => true}.merge(options)


    data = Open.to_hash(lexicon, options)
    if options[:clean]
      data = ArrayHash.clean(data)
    end

    index = {}

    data.each{|code, id_lists|
      next if code.nil? || code == ""
      id_lists.flatten.compact.uniq.each{|id|
        id = id.downcase unless options[:case_sensitive]
        index[id] = code
      }
    }
    data.each{|code, id_lists|
      next if code.nil? || code == ""
      id = code
      id = id.downcase unless options[:case_sensitive]
      index[id] = code
    }

    if !options[:case_sensitive]
      class << index; self; end.instance_eval{
        alias_method :old_get, :[]
        define_method(:[], proc{|key| old_get(key.to_s.downcase)})
      }
    end

    index
  end
end

if __FILE__ == $0

  require 'benchmark'

  normal = nil
  puts "Normal " + Benchmark.measure{
    normal = Index.index('/home/miki/rbbt/data/organisms/human/identifiers',:trie => false, :case_sensitive => false)
  }.to_s


  ids = Open.read('/home/miki/git/MARQ/test/GDS1375_malignant_vs_normal_up.genes').collect{|l| l.chomp.strip.upcase}

  new = nil

  puts ids.inspect
  puts "normal " + Benchmark.measure{
    100.times{
      new = ids.collect{|id| normal[id]}
    }
  }.to_s

  puts new.inspect

end
