require 'rbbt/util/misc'
tokens do

  # Some (possible) single letters first
  receptor     /^(?:receptor|r)s?$/i 
  protein      /^(?:protein|p)s?$/i 
  roman        /^[IV]+$/ 
  greek_letter do |w| $inverse_greek[w.downcase] != nil end
  

  # Some words for removal 
  stopword     do |w|  $stopwords.include?( w.downcase_first)  end
  gene         /genes?/i 
  dna
  cdna
  rna
  mrna
  trna
  cdna
  component
  exon
  intron
  domain
  family


  # Important words
  number       /^(?:\d+[.,]?\d+|\d)$/ 
  greek        do |w| $greek[w.downcase] != nil end
  special      do |w| w.is_special? end 
  promoter
  similar      /^(homolog.*|like|related|associated)$/ 
  ase          /ase$/ 
  in_end       /in$/ 
end

comparisons do 

  compare.number do |l1,l2|
      v = 0
      case
      when l1.empty? && l2.empty?
          v = 0
      when l1.sort.uniq == l2.sort.uniq
          v = 3
      when l1.any? && l1[0] == l2[0] 
          v = -3   
      when l1.empty? && l2 == ['1'] 
          v = -5   
      else 
          v = -10
      end
      v
  end

  diff.promoter   -10 
  diff.receptor   -10 
  diff.similar    -10 
  diff.capital    -10 

  same.unknown      1
  miss.unknown      -2 
  extr.unknown      -2 

  same.greek      1
  miss.greek      -2 
  extr.greek      -2 

  same.special    4
  miss.special    -3 
  extr.special    -3 

  transform.roman do |t| [t.arabic, :number] end
  transform.greek_letter do |t| [$inverse_greek[t.downcase], :greek] end
  transform.ase do |t| [t, :special] end
  transform.in_end do |t| [t, :special] end
  transform.unknown do |t| [t, (t.length < 4 ? :special : :unknown)] end
end

