require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Arabidopsis thaliana"


$native_id = "TAIR Locus"

$entrez2native = {
  :tax =>3702,
  :fix => proc{|code| code.sub(/^TAIR:/,'')},
  :check => proc{|code| true },
}

$lexicon = {
  :file => {
    :url => "ftp://ftp.arabidopsis.org/home/tair/Genes/gene_aliases.20090313",
    :native => 0,
    :extra => [1,2],
  },
}

$identifiers = {
  :file => {
    :url => "ftp://ftp.arabidopsis.org/home/tair/Genes/gene_aliases.20090313",
    :native => 0,
    :extra => [],
  },
  :biomart => {
    :database => 'athaliana_eg_gene',
    :main => ['TAIR Locus', 'tair_locus'],
    :extra => [
      ['Associated Gene Name' , "external_gene_id"] ,
      ['Gramene Gene ID' , "ensembl_gene_id"] ,
      ['RefSeq peptide' , "refseq_peptide"] ,
      ['Unigene' , "unigene"] ,
      ['Interpro ID' , "interpro"] ,
  
  
    ],
    :filter => ['with_tair_locus'], # This is needed as the filter is not with_mgi_id as was expected
  }

}

$go = {
  :url =>  "ftp://ftp.arabidopsis.org/home/tair/Ontologies/Gene_Ontology/ATH_GO_GOSLIM.txt",
  :code => 0,
  :go   => 5,
  :pmid => 12,
}

$query = '("arabidopsis"[MeSH Terms] OR Arabidopsis[Text Word]) AND ((("proteins"[TIAB] NOT Medline[SB]) OR "proteins"[MeSH Terms] OR protein[Text Word]) OR (("genes"[TIAB] NOT Medline[SB]) OR "genes"[MeSH Terms] OR gene[Text Word]))'


