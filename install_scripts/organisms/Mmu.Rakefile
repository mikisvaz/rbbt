require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Mus musculus"


$native_id = "MGI DB ID"

$entrez2native = {
  :tax => 10090,
  :fix => nil,
  :check => proc{|code| code.match(/^MGI/)},
}

$lexicon = {
  :file => {
    :url =>  "ftp://ftp.informatics.jax.org/pub/reports/MGI_Coordinate.rpt",
    :native => 0,
    :extra => [2,3],
    :exclude => proc{|l| l.split(/\t/)[1] != "Gene"},
  },
}

$identifiers = {
  :file => {
    :url =>  "ftp://ftp.informatics.jax.org/pub/reports/MGI_Coordinate.rpt",
    :native => 0,
    :extra => [],
    :exclude => proc{|l| l.split(/\t/)[1] != "Gene"},
  },
  :biomart => {
    :database => 'mmusculus_gene_ensembl',
    :main => ['MGI DB ID', 'mgi_id'] , 
    :extra => [ 
      ['Associated Gene Name' , "external_gene_id"], 
      ['Protein ID' , "protein_id"] , 
      ['UniProt/SwissProt ID' , "uniprot_swissprot"] , 
      ['Unigene ID' , "unigene"] , 
      ['UniProt/SwissProt Accession' , "uniprot_swissprot_accession"] , 
      ['RefSeq Protein ID' , "refseq_peptide"] , 
      ['EMBL (Genbank) ID' , "embl"] , 

      ['Affy mg u74a',"affy_mg_u74a" ],
      ['Affy mg u74av2',"affy_mg_u74av2" ],
      ['Affy mg u74b',"affy_mg_u74b" ],
      ['Affy mg u74bv2',"affy_mg_u74bv2" ],
      ['Affy mg u74c',"affy_mg_u74c" ],
      ['Affy mg u74cv2',"affy_mg_u74cv2" ],
      ['Affy moe430a',"affy_moe430a" ],
      ['Affy moe430b',"affy_moe430b" ],
      ['AFFY MoEx',"affy_moex_1_0_st_v1" ],
      ['AFFY MoGene',"affy_mogene_1_0_st_v1" ],
      ['Affy mouse430 2',"affy_mouse430_2" ],
      ['Affy mouse430a 2',"affy_mouse430a_2" ],
      ['Affy mu11ksuba',"affy_mu11ksuba" ],
      ['Affy mu11ksubb',"affy_mu11ksubb" ],
      ['Agilent WholeGenome',"agilent_wholegenome" ],
      ['Codelink ID',"codelink" ],
      ['Illumina MouseWG 6 v1',"illumina_mousewg_6_v1" ],
      ['Illumina MouseWG 6 v2',"illumina_mousewg_6_v2" ],

    ],
    :filter => ['with_mgi'], # This is needed as the filter is not with_mgi_id as was expected
  }
}

$go = {
  :url => "ftp://ftp.geneontology.org/go/gene-associations/gene_association.mgi.gz",
  :code => 1,
  :go   => 4,
  :pmid => 5,
}

$query = '(("mice"[TIAB] NOT Medline[SB]) OR "mice"[MeSH Terms] OR mouse[Text Word]) AND ((("genes"[TIAB] NOT Medline[SB]) OR "genes"[MeSH Terms] OR gene[Text Word]) OR (("proteins"[TIAB] NOT Medline[SB]) OR "proteins"[MeSH Terms] OR protein[Text Word]))'
##########################



