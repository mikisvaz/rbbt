#!/usr/bin/ruby

require 'rbbt/sources/organism'
require 'rbbt/sources/pubmed'

usage =<<-EOT
  Usage: #{$0} organism 
  
  organism = sgd, rgd, mgi, etc. See 'rbbt_config organisms'
  
  You will need to have the organism installed. Example: 'rbbt_config prepare organism -o sgd'. This scripts reads the identifiers from STDIN.
  
  Example: 
  cat yeast_identifiers.txt | #{$0} sgd 
EOT

organism = ARGV[0] 

if organism.nil? 
  puts usage 
  exit
end

index = Organism.id_index(organism, :native => 'Entrez Gene Id')
STDIN.each_line{|l| puts "#{l.chomp} => #{index[l.chomp]}"}


