require 'rbbt/util/open'
require 'rbbt/util/arrayHash'

module Index

  # Creates an inverse index. Takes a file with rows of elements
  # separated by a given pattern (specified by +sep+) and returns a hash
  # where each element points to the first element in the row. +lexicon+
  # is the file containing the data.
  def self.index(lexicon, options = {}) 
    options = {:sep => "\t", :sep2 => '\|', :case_sensitive => true}.merge(options)


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

        alias_method :old_values_at, :values_at
        define_method(:values_at, proc{|*keys| old_values_at(*keys.collect{|key| key.to_s.downcase }) })
      }
    end

    index
  end
end
