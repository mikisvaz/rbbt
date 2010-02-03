require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Schizosaccharomyces pombe"


$native_id = "GeneDB Id"

$entrez2native = {
  :tax => 4896,
  :fix => proc{|code| code.sub(/GeneDB:SP/,'SP') },
  :check => proc{|code| code.match(/^SP/)},
}

$lexicon = {
  :file => {
    :url => 'ftp://ftp.sanger.ac.uk/pub/yeast/pombe/Mappings/allNames.txt',
    :native => 0,
    :extra => [1,2,3,4,5,6,7,8]
  },
}

$identifiers = {
  :file => {
    :url => 'ftp://ftp.sanger.ac.uk/pub/yeast/pombe/Mappings/allNames.txt',
    :native => 0,
    :extra => [],
  },
}

$go = {
  :url => "ftp://ftp.sanger.ac.uk/pub/yeast/pombe/Gene_ontology/gene_association.GeneDB_Spombe",
  :code => 1,
  :go   => 4,
  :pmid => 5,
}

$query = 'pombe[All Fields] AND (hasabstract[text] AND English[lang])'
####


