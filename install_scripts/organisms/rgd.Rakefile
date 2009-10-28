require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Rattus norvegicus"


$native_id = "RGD DB ID"

$entrez2native = {
  :tax => 10116,
  :check => proc{|code| code.match(/^RGD/)},
}

$lexicon = {
  :file => {
    :url => "ftp://rgd.mcw.edu/pub/data_release/gene_association.rgd.gz",
    :native => 1,
    :extra => [2,9],
    :exclude => proc{|l| !l.match(/^RGD/)}
  },
}

$identifiers = {
  :file => {
    :url => "ftp://rgd.mcw.edu/pub/data_release/gene_association.rgd.gz",
    :native => 1,
    :extra => [],
    :exclude => proc{|l| !l.match(/^RGD/)}
  },
  :biomart => {
    :database => 'rnorvegicus_gene_ensembl',
    :main =>  ['Entrez Gene ID' , "entrezgene"], 
    :extra => [ 
      ['Associated Gene Name' , "external_gene_id"], 
      ['Protein ID' , "protein_id"] , 
      ['UniProt/SwissProt ID' , "uniprot_swissprot"] , 
      ['UniProt/SwissProt Accession' , "uniprot_swissprot_accession"] , 
      ['RefSeq Protein ID' , "refseq_peptide"] , 
      ['EMBL (Genbank) ID' , "embl"] , 

      ['Affy rae230a', "affy_rae230a"],
      ['Affy rae230b', "affy_rae230b"],
      ['Affy RaGene', "affy_ragene_1_0_st_v1"],
      ['Affy rat230 2', "affy_rat230_2"],
      ['Affy RaEx', "affy_raex_1_0_st_v1"],
      ['Affy rg u34a', "affy_rg_u34a"],
      ['Affy rg u34b', "affy_rg_u34b"],
      ['Affy rg u34c', "affy_rg_u34c"],
      ['Affy rn u34', "affy_rn_u34"],
      ['Affy rt u34', "affy_rt_u34"],
      ['Agilent WholeGenome',"agilent_wholegenome" ],
      ['Codelink ID ', "codelink"],


    ],
    :filter => [],
  }
}

$go = {
  :url => "ftp://rgd.mcw.edu/pub/data_release/gene_association.rgd.gz",
  :exclude => proc{|l| !l.match(/^RGD/)},
  :code => 1,
  :go   => 4,
  :pmid => 5,
}

$query = '(("mice"[TIAB] NOT Medline[SB]) OR "mice"[MeSH Terms] OR mouse[Text Word]) AND ((("proteins"[TIAB] NOT Medline[SB]) OR "proteins"[MeSH Terms] OR protein[Text Word]) OR (("genes"[TIAB] NOT Medline[SB]) OR "genes"[MeSH Terms] OR gene[Text Word]))  AND hasabstract[text] AND English[lang]'

#{{{ Redefines

module Open

  class << self
    alias_method :old_read, :read

    def read(url, options = {})
      data = old_read(url, options)

      if url =~ /gene_association.rgd.gz/
        return data.collect{|l| l.gsub(/^RGD\t/,"RGD\tRGD:")}.join("\n")
      else
        return data
      end

    end
  end
end

