#!/usr/bin/ruby

require 'rbbt/sources/organism'
require 'rbbt/sources/pubmed'

usage =<<-EOT
  Usage: #{$0} organism query [type] [max]
  
  organism = Sc, Rn, Mm, etc. See 'rbbt_config organisms'
  type     = rner, abner, or banner. Defaults to rner
  max_docs = maximum number of articles to process. Defaults to 500

  You will need to have the organism installed. Example: 'rbbt_config prepare organism -o Sc'. Depending on
  the type of ner you will need to do 'rbbt_config prepare java_ner' or 'rbbt_config prepare rner; rbbt_config install ner'.
  
  Example: 
  #{$0} Sc "'saccharomyces cerevisiae' sexual reproduction" rner 500
EOT

organism = ARGV[0] 
query    = ARGV[1]
type     = ARGV[2] || :rner # :abner, :banner, :rner
max      = ARGV[3] || 500

if organism.nil? or query.nil?
  puts usage 
  exit
end

ner = Organism.ner(organism, type )

puts "Loading normalizer"
norm = Organism.norm(organism)

pmids = PubMed.query(query, max.to_i)

PubMed.get_article(pmids).each{|pmid,article|
  mentions = ner.extract(article.text)
  codes = {}
  mentions.collect{|mention| codes[mention] = norm.resolve(mention, article.text)}
  puts pmid
  puts article.text
  puts "Mentions: " 
  codes.each{|mention, list|
    puts "#{ mention } => #{list.join(", ")}"
  }
  puts
}

