require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Homo sapiens"


$native_id = "Entrez Gene ID"

$entrez2native = {
  :tax => 9606,
  :fix => nil,
  :check => proc{|code| false},
}

$lexicon = {
  :biomart => {
    :database => 'hsapiens_gene_ensembl',
    :main => ['Entrez Gene ID' , "entrezgene"], 
    :extra => [ 
      [ 'Associated Gene Name' , "external_gene_id"], 
      [ 'HGNC symbol', "hgnc_symbol"  ],
      [ 'HGNC automatic gene name', "hgnc_automatic_gene_name"  ],
      [ 'HGNC curated gene name ', "hgnc_curated_gene_name"  ],
    ],
  }

}

$identifiers = {
  :biomart => {
    :database => 'hsapiens_gene_ensembl',
    :main => ['Entrez Gene ID' , "entrezgene"], 
    :extra => [ 
      [ 'Ensembl Gene ID', "ensembl_gene_id"  ],
      [ 'Ensembl Protein ID', "ensembl_peptide_id"  ],
      [ 'Associated Gene Name', "external_gene_id"  ],
      [ 'CCDS ID', "ccds"  ],
      [ 'Protein ID', "protein_id"  ],
      [ 'RefSeq Protein ID', "refseq_peptide"  ],
      [ 'Unigene ID', "unigene"  ],
      [ 'UniProt/SwissProt ID', "uniprot_swissprot"  ],
      [ 'UniProt/SwissProt Accession', "uniprot_swissprot_accession"  ],
      [ 'HGNC ID', "hgnc_id", 'HGNC'],
      ['EMBL (Genbank) ID' , "embl"] , 

      # Affymetrix
      [ 'AFFY HC G110', 'affy_hc_g110' ],
      [ 'AFFY HG FOCUS', 'affy_hg_focus' ],
      [ 'AFFY HG U133-PLUS-2', 'affy_hg_u133_plus_2' ],
      [ 'AFFY HG U133A_2', 'affy_hg_u133a_2' ],
      [ 'AFFY HG U133A', 'affy_hg_u133a' ],
      [ 'AFFY HG U133B', 'affy_hg_u133b' ],
      [ 'AFFY HG U95AV2', 'affy_hg_u95av2' ],
      [ 'AFFY HG U95B', 'affy_hg_u95b' ],
      [ 'AFFY HG U95C', 'affy_hg_u95c' ],
      [ 'AFFY HG U95D', 'affy_hg_u95d' ],
      [ 'AFFY HG U95E', 'affy_hg_u95e' ],
      [ 'AFFY HG U95A', 'affy_hg_u95a' ],
      [ 'AFFY HUGENEFL', 'affy_hugenefl' ],
      [ 'AFFY HuEx', 'affy_huex_1_0_st_v2' ],
      [ 'AFFY HuGene', 'affy_hugene_1_0_st_v1' ],
      [ 'AFFY U133 X3P', 'affy_u133_x3p' ],
      [ 'Agilent WholeGenome',"agilent_wholegenome" ],
      [ 'Agilent CGH 44b', 'agilent_cgh_44b' ],
      [ 'Codelink ID', 'codelink' ],
      [ 'Illumina HumanWG 6 v2', 'illumina_humanwg_6_v2' ],
      [ 'Illumina HumanWG 6 v3', 'illumina_humanwg_6_v3' ],

    ],
    :filter => [],
  }
}

$go = {
 :url => "http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association.goa_human.gz?rev=HEAD",
 :code => 2,
 :go   => 4,
 :pmid => 5,
}

$query = '"humans"[MeSH Terms] AND ((("genes"[TIAB] NOT Medline[SB]) OR "genes"[MeSH Terms] OR gene[Text Word]) OR (("proteins"[TIAB] NOT Medline[SB]) OR "proteins"[MeSH Terms] OR protein[Text Word])) AND (hasabstract[text] AND "humans"[MeSH Terms] AND English[lang])'
##########################

require 'rbbt/util/index'

Rake::Task['gene.go'].clear
file 'gene.go' => ['identifiers'] do 
  if File.exists? 'identifiers'
    require 'rbbt/sources/organism'
    index = Organism.id_index('Hsa', :other => ['Associated Gene Name'])
    data = Open.to_hash($go[:url], :native => $go[:code], :extra => $go[:go], :exclude => $go[:exclude])

    data = data.collect{|code, value_lists|
      code = index[code]
      [code, value_lists.flatten.select{|ref| ref =~ /GO:\d+/}.collect{|ref| ref.match(/(GO:\d+)/)[1]}]
    }.select{|p| p[0] && p[1].any?}

    Open.write('gene.go', 
               data.collect{|p| 
                 "#{p[0]}\t#{p[1].uniq.join("|")}"
               }.join("\n")
              )
  end
end

Rake::Task['gene_go.pmid'].clear
file 'gene_go.pmid' => ['identifiers'] do
  if File.exists? 'identifiers'
    index = Index.index('identifiers')
    data = Open.to_hash($go[:url], :native => $go[:code], :extra => $go[:pmid], :exclude => $go[:exclude])

    data = data.collect{|code, value_lists|
      code = index[code]
      [code, value_lists.flatten.select{|ref| ref =~ /PMID:\d+/}.collect{|ref| ref.match(/PMID:(\d+)/)[1]}]
    }.select{|p| p[0] && p[1].any?}

    Open.write('gene_go.pmid', 
               data.collect{|p| 
                 "#{p[0]}\t#{p[1].uniq.join("|")}"
               }.join("\n")
              )
  end
end


Rake::Task['lexicon'].clear
file 'lexicon' => ['identifiers'] do
  if File.exists? 'identifiers'
    require 'rbbt/sources/organism'
    HGNC_URL = 'http://www.genenames.org/cgi-bin/hgnc_downloads.cgi?title=HGNC+output+data&hgnc_dbtag=on&col=gd_hgnc_id&col=gd_app_sym&col=gd_app_name&col=gd_prev_sym&col=gd_prev_name&col=gd_aliases&col=gd_name_aliases&col=gd_pub_acc_ids&status=Approved&status_opt=2&level=pri&=on&where=&order_by=gd_app_sym_sort&limit=&format=text&submit=submit&.cgifields=&.cgifields=level&.cgifields=chr&.cgifields=status&.cgifields=hgnc_dbtag'
    names = Open.to_hash(HGNC_URL, :exclude => proc{|l| l.match(/^HGNC ID/)}, :flatten => true)
    translations = Organism.id_index('Hsa', :native => 'Entrez Gene ID', :other => ['HGNC ID'])

    Open.write('lexicon',
               names.collect{|code, names|
                 next unless translations[code]
                 ([translations[code]] + names).join("\t")
               }.compact.join("\n")
               )
  end

end
