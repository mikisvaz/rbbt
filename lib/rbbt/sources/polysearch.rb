require 'rbbt'
require 'rbbt/util/open'
require 'rbbt/ner/regexpNER'

# Find terms in the Polysearch thesauri using simple regular expression
# matching. Note that the first time the methods are used the correspondent
# thesaurus are loaded into memory. The available thesauri are: disease, drug,
# metabolite, organ, subcellular (subcellular localization) and tissue.
module Polysearch

  
  @@names = {}
  def self.type_names(type) #:nodoc:
    @@names[type] ||= Open.to_hash(File.join(Rbbt.datadir,'dbs','polysearch',type.to_s + '.txt'), :single => true)
  end


  @@indexes = {}
  def self.type_index(type) #:nodoc:
    @@indexes[type] ||= RegExpNER.new(File.join(Rbbt.datadir,'dbs','polysearch',type.to_s + '.txt'))
  end

  # Find matches in a string of text, the types array specifies which thesauri
  # to use, if if nil it will use all.
  def self.match(text, types = nil)
    if types.nil? 
      types = %w(disease  drug  metabolite  organ  subcellular  tissue)
    end

    types = [types] unless Array === types
    types = types.sort

    matches = {}
    types.collect{|type|
      matches.merge!(type_index(type).match_hash(text))
    }

    matches
  end

  # Transform the code into a name, type is the thesaurus to use
  def self.name(type, code)
    type_names(type)[code]
  end

end

if __FILE__ == $0 

    text =<<-EOT

     Background  Microorganisms adapt their transcriptome by integrating
     multiple chemical and physical signals from their environment. Shake-flask
    cultivation does not allow precise manipulation of individual culture
    parameters and therefore precludes a quantitative analysis of the
    (combinatorial) influence of these parameters on transcriptional
    regulation. Steady-state chemostat cultures, which do enable accurate
    control, measurement and manipulation of individual cultivation parameters
    (e.g. specific growth rate, temperature, identity of the growth-limiting
     nutrient) appear to provide a promising experimental platform for such a
     combinatorial analysis. Results  A microarray compendium of 170
     steady-state chemostat cultures of the yeast Saccharomyces cerevisiae is
     presented and analyzed. The 170 microarrays encompass 55 unique
     conditions, which can be characterized by the combined settings of 10
     different cultivation parameters. By applying a regression model to assess
     the impact of (combinations of) cultivation parameters on the
     transcriptome, most S. cerevisiae genes were shown to be influenced by
     multiple cultivation parameters, and in many cases by combinatorial
     effects of cultivation parameters. The inclusion of these combinatorial
     effects in the regression model led to higher explained variance of the
     gene expression patterns and resulted in higher function enrichment in
     subsequent analysis. We further demonstrate the usefulness of the
     compendium and regression analysis for interpretation of shake-flask-based
     transcriptome studies and for guiding functional analysis of
     (uncharacterized) genes and pathways. Conclusions  Modeling the
     combinatorial effects of environmental parameters on the transcriptome is
     crucial for understanding transcriptional regulation. Chemostat
     cultivation offers a powerful tool for such an approach. Keywords:
       chemostat steady state samples 
    Cerebellar 
    stroke syndrome
       
    
    EOT

    p Polysearch.match(text,'disease').values.flatten
 
end
