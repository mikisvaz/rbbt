require 'rbbt'
require 'rbbt/ner/rnorm/cue_index'
require 'rbbt/ner/rnorm/tokens'
require 'rbbt/util/index'
require 'rbbt/util/open'
require 'rbbt/sources/entrez'

class Normalizer


  # Given a list of pairs of candidates along with their scores as
  # parameter +values+, and a minimum value for the scores. It returns
  # a list of pairs of the candidates that score the highest and that
  # score above the minimum. Otherwise it return an empty list.
  def self.get_best(values, min)
    return [] if values.empty?
    best = values.collect{|p| p[1]}.max
    return [] if best < min
    values.select{|p| p[1] == best}
  end

  # Compares the tokens and gives each candidate a score based on the
  # commonalities and differences amongst the tokens.
  def token_score(candidates, mention)
    candidates.collect{|code|
      next if @synonyms[code].nil?
      value = @synonyms[code].select{|name| name =~ /\w/}.collect{|name|
        case 
        when mention == name
          100
        when mention.downcase == name.downcase
          90
        when mention.downcase.gsub(/\s/,'') == name.downcase.gsub(/\s/,'')
          80
        else
          @tokens.evaluate(mention, name)
        end
      }.max
      [code, value]
    }.compact
  end

  # Order candidates with the number of words in common between the text
  # in their Entrez Gene entry and the text passed as parameter. Because
  # candidate genes might be in some other format than Entrez Gene Ids,
  # the +to_entrez+ variable can hold the way to translate between them,
  # been a Proc or a Hash.
  def entrez_score(candidates, text, to_entrez = nil)
      code2entrez = {}
      candidates.each{|code|
        if to_entrez.is_a? Proc
          entrez = to_entrez.call(code)
        elsif to_entrez.is_a? Hash
          entrez = @to_entrez[code]
        else
          entrez = code
        end
        code2entrez[code] = entrez unless entrez.nil? 
      }

      # Get all at once, better performance

      genes = Entrez.get_gene(code2entrez.values)
      code2entrez_genes = code2entrez.collect{|p| [p[0], genes[p[1]]]}

      code2entrez_genes.collect{|p|
        [p[0], Entrez.gene_text_similarity(p[1], text)]
      }
  end
  
  # Takes a list of candidate codes and selects the ones that have the
  # mention explicitly in their list of synonyms, and in the earliest
  # positions. This is based on the idea that synonym list order their
  # synonyms by importance.
  def appearence_order(candidates, mention)
    positions = candidates.collect{|code|
      next unless @synonyms[code]
      pos = nil
      @synonyms[code].each_with_index{|list,i|
        next if pos
        pos = i if list.include? mention
      }
      pos
    }
    return nil if positions.compact.empty?
    best = candidates.zip(positions).sort{|a,b| a[1] <=> b[1]}.first[1]
    candidates.zip(positions).select{|p| p[1] == best}.collect{|p| p[0]}
  end



  def initialize(lexicon, options = {})
    @synonyms = Open.to_hash(lexicon, :sep => "\t|\\|", :flatten => true)

    @index = CueIndex.new
    @index.load(lexicon, options[:max_candidates])

    @to_entrez = options[:to_entrez]
    @tokens = Tokenizer.new(options[:file])
  end

  def match(mention)
    @index.match(mention)
  end

  def select(candidates, mention, text = nil, options = {})
    threshold  = options[:threshold] || 0
    max_candidates  = options[:max_candidates] || 200
    max_entrez  = options[:max_entrez] || 10

    # Abort if too ambigous
    return [] if candidates.empty?
    return [] if candidates.length > max_candidates

    scores = token_score(candidates, mention)
    best_codes = Normalizer::get_best(scores, threshold).collect{|p| p[0]}

    # Abort if too ambigous
    return [] if best_codes.length > max_entrez

    if best_codes.length > 1 and text
      scores = entrez_score(best_codes, text, @to_entrez)

      Normalizer::get_best(scores, 0).collect{|p| p[0]}
    else
      orders = appearence_order(best_codes, mention)
      if orders 
        orders
      else
        best_codes
      end
    end

  end

  def resolve(mention, text = nil, options = {})
    candidates = match(mention)
    select(candidates, mention, text, options)
  end

end

