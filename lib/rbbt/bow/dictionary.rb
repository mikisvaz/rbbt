class Dictionary
  attr_reader :terms
  def initialize
    @terms = Hash.new(0)
  end

  def add(terms, &block)
    terms.each{|term, count|
      @terms[term] += count
    }
  end
end

class Dictionary::TF_IDF 
  attr_reader :terms, :docs, :total_terms, :num_docs

  def initialize(options = {})
    @term_limit = {
      :limit => 500_000,
    }.merge(options)[:limit]

    @terms = Hash.new(0)
    @docs = Hash.new(0)
    @num_docs = 0
    @total_terms = 0
  end


  def add(terms)
    if @term_limit && @terms.length > @term_limit
      terms = terms.delete_if{|term, count| !@terms.include? term }
    end

    terms.each{|term, count|
      @terms[term] += count
      @total_terms += count
      @docs[term]  += 1
    }
    @num_docs += 1
  end

  def df
    df = Hash.new(0)
    @docs.each{|term, count|
     df[term] = count.to_f / @num_docs
    }
    df
  end

  def tf
    tf = Hash.new(0)
    @terms.each{|term, count|
     tf[term] = count.to_f / @total_terms
    }
    tf
  end

  def idf
    idf = Hash.new(0)
    num_docs = @num_docs.to_f
    @docs.each{|term, count|
     idf[term] = Math::log(num_docs / count)
    }
    idf
  end

  def tf_idf
    tf_idf = Hash.new(0)
    num_docs = @num_docs.to_f
    @docs.each{|term, count|
     tf_idf[term] = @terms[term].to_f / @total_terms * Math::log(num_docs / count)
    }
    tf_idf
  end

  def best(options = {})
    hi, low, limit = {
      :low   => 0,
      :hi    => 1,
    }.merge(options).
    values_at(:hi, :low, :limit)

    num_docs = @num_docs.to_f
    best = df.select{|term, value|
      value >= low && value <= hi
    }.collect{|p| 
      term     = p.first
      df_value = p.last
      [term,
       @terms[term].to_f / num_docs * Math::log(1.0/df_value)
      ]
    }
    if limit
      Hash[*best.sort{|a,b| b[1] <=>  a[1]}.slice(0, limit).flatten]
    else
      Hash[*best.flatten]
    end
  end

  def weights(options = {})
    best_terms = best(options).keys
    weights = {}

    num_docs = @num_docs.to_f
    best_terms.each{|term|
      weights[term] = Math::log(num_docs / @docs[term])
    }
    weights
  end

end

class Dictionary::KL
  attr_reader :pos_dict, :neg_dict

  def initialize(options = {})
    @pos_dict = Dictionary::TF_IDF.new(options)
    @neg_dict = Dictionary::TF_IDF.new(options)
  end

  def terms
    (pos_dict.terms.keys + neg_dict.terms.keys).uniq
  end

  def add(terms, c)
    dict = (c == :+ || c == '+' ? @pos_dict : @neg_dict)
    dict.add(terms)
  end

  def kl
    kl = {}
    pos_df = @pos_dict.df
    neg_df = @neg_dict.df

    terms.each{|term|
      pos = pos_df[term]
      neg = neg_df[term]

      pos = 0.000001 if pos == 0
      pos = 0.999999 if pos == 1
      neg = 0.000001 if neg == 0
      neg = 0.999999 if neg == 1

      kl[term] = pos * Math::log(pos / neg) + neg * Math::log(neg / pos)
    }
    kl
  end
  
  def best(options = {})
    hi, low, limit = {
      :low   => 0,
      :hi    => 1,
    }.merge(options).
    values_at(:hi, :low, :limit)

    pos_df = @pos_dict.df
    neg_df = @neg_dict.df

    best = {}
    terms.select{|term|
      pos_df[term] >= low && pos_df[term] <= hi ||
      neg_df[term] >= low && neg_df[term] <= hi 
    }.each{|term|
      pos = pos_df[term]
      neg = neg_df[term]

      pos = 0.000001 if pos == 0
      pos = 0.999999 if pos == 1
      neg = 0.000001 if neg == 0
      neg = 0.999999 if neg == 1

      best[term] = pos * Math::log(pos / neg) + neg * Math::log(neg / pos)
    }
    if limit
      Hash[*best.sort{|a,b| b[1] <=>  a[1]}.slice(0, limit).flatten]
    else
      Hash[*best.flatten]
    end
  end

  def weights(options = {})
    best(options)
  end

   
    
end

if __FILE__ == $0

  require 'benchmark'
  require 'rbbt/sources/pubmed'
  require 'rbbt/bow/bow'
  require 'progress-monitor'

  max = 10000

  pmids = PubMed.query("Homo Sapiens", max)
  Progress.monitor "Get pimds"
  docs = PubMed.get_article(pmids).values.collect{|article| BagOfWords.terms(article.text)}

  dict = Dictionary::TF_IDF.new()

  puts "Starting Benchmark"
  puts Benchmark.measure{
    docs.each{|doc|
      dict.add doc
    }
  }
  puts Benchmark.measure{
    dict.weights
  }

  puts dict.terms.length


end

