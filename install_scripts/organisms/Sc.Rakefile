require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Saccharomyces cerevisiae"


$native_id = "SGD DB Id"

$entrez2native = {
  :tax =>  4932,
  :fix => proc{|code| code.sub(/SGD:S0/,'S0') },
  :check => proc{|code| code.match(/^S0/)},
}

$lexicon = {
  :file => {
    :url => "ftp://genome-ftp.stanford.edu/pub/yeast/data_download/chromosomal_feature/SGD_features.tab",
    :native => 0,
    :extra => [4,3,5]
  },
  :biomart => {
    :database => 'scerevisiae_gene_ensembl',
    :main => ['Entrez Gene ID', 'entrezgene'],
    :extra => [ 
      ['Interpro Description' , "interpro_description"], 
    ],
    :filter => [],
  }

}

$identifiers = {
  :file => {
    :url => "ftp://genome-ftp.stanford.edu/pub/yeast/data_download/chromosomal_feature/SGD_features.tab",
    :native => 0,
    :extra => [],
  },
  :biomart => {
    :database => 'scerevisiae_gene_ensembl',
    :main => ['Entrez Gene ID', 'entrezgene'],
    :extra => [ 
      ['Associated Gene Name' , "external_gene_id"], 
      ['Ensembl Gene ID', "ensembl_gene_id"  ],
      ['Ensembl Protein ID', "ensembl_peptide_id"  ],
      ['RefSeq Protein ID' , "refseq_peptide"] , 
      ['UniProt/SwissProt ID' , "uniprot_swissprot"] , 
      ['UniProt/SwissProt Accession' , "uniprot_swissprot_accession"] , 
      ['Protein ID' , "protein_id"] , 
      ['EMBL (Genbank) ID' , "embl"] , 
      # Affymetrix
      ['Affy yeast 2',"affy_yeast_2"],
      ['Affy yg s98', "affy_yg_s98"],
    ],
    :filter => [],
  }
}

$go = {
  :url => "ftp://genome-ftp.stanford.edu/pub/yeast/data_download/literature_curation/gene_association.sgd.gz",
  :code => 1,
  :go   => 4,
  :pmid => 5,
}

$query = '"saccharomyces cerevisiae"[All Fields] AND ((("proteins"[TIAB] NOT Medline[SB]) OR "proteins"[MeSH Terms] OR protein[Text Word]) OR (("genes"[TIAB] NOT Medline[SB]) OR "genes"[MeSH Terms] OR gene[Text Word]))  AND hasabstract[text] AND English[lang]'


