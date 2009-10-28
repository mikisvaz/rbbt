require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Caenorhabditis elegans "


$native_id = "WormBase ID"

$entrez2native = {
  :tax => 6239,
  :fix => proc{|code| code.sub(/^WormBase:/,'')},
  :check => proc{|code| code.match(/^WBGene/)},
}

$lexicon = {

  :file =>{

    :url => "ftp://ftp.wormbase.org/pub/wormbase/genomes/elegans/annotations/GO/current.txt.gz",
    :native => 0,
    :extra   => [1,2], 

#    :url => "ftp://ftp.wormbase.org/pub/wormbase/genomes/elegans/annotations/gene_ids/current.gz",
#    :native => 0,
#    :extra => [2,3,4,5],
  
  },
}


$identifiers = {

  :file =>{

    :url => "ftp://ftp.wormbase.org/pub/wormbase/genomes/elegans/annotations/GO/current.txt.gz",
    :native => 0,
    :extra   => [1,2], 

#    :url => "ftp://ftp.wormbase.org/pub/wormbase/genomes/elegans/annotations/gene_ids/current.gz",
#    :native => 0,
#    :extra => [2,3,4,5],
  
  },

  :biomart => {
    :database => 'celegans_gene_ensembl',
    :main => ['Entrez Gene ID' , "entrezgene"], 
    :extra => [ 
      ['WormBase gene', "wormbase_gene"  ],
      ['Associated Gene Name ', "external_gene_id"  ],
      ['WormPep id', "wormpep_id"  ],
      [ 'Ensembl Gene ID', "ensembl_gene_id"  ],
      [ 'Ensembl Protein ID', "ensembl_peptide_id"  ],
      [ 'Protein ID ', "protein_id"  ],
      [ 'RefSeq Protein ID ', "refseq_peptide"  ],
      [ 'Unigene ID ', "unigene"  ],
      [ 'UniProt/SwissProt ID', "uniprot_swissprot"  ],
      [ 'UniProt/SwissProt Accession', "uniprot_swissprot_accession"  ],
      ['EMBL (Genbank) ID' , "embl"] , 
    ],
    :filter => [],
  }
}

$go = {
  :url => "ftp://ftp.wormbase.org/pub/wormbase/genomes/elegans/annotations/GO/current.txt.gz",
  :code => 0,
  :go   => 3,
  :pmid => 3,
}

$query = '"caenorhabditis elegans"[MeSH Terms] OR Caenorhabditis elegans[Text Word]'
##########################


module Open

  class << self
    alias_method :old_read, :read

    def read(url, options = {})
      content = old_read(url, options)

      if url =~ /GO/
        return content.gsub(/.*:.*\((GO:\d+)\)/,'\1').gsub(/\nGO/,"|GO").
                collect{|l|
                  l = l.sub(/\|/,"\t")
                  names, gos = l.chomp.split(/\t/)

                  id, name, extra = names.split(/ /)
                  extra = extra.gsub(/[()]/,'') if extra

                  if gos
                    gos.split(/\|/).collect{|go|
                      [id, name, extra, go].join("\t")
                    }.join("\n")
                  else
                    [id, name, extra].join("\t") + "\n"
                  end
                }
      elsif url =~ /gene_ids/
        return content.gsub(/,/,"\t")
      else
        return content
      end

    end
  end
end

