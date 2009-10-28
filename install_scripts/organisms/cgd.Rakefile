require __FILE__.sub(/[^\/]*$/,'') + '../rake-include'

$name = "Candida albicans"


$native_id = "Systematic Name"

$entrez2native = {
  :tax => 237561,
  :fix => proc{|code| code.sub(/^CaO/,'orf') },
  :check => proc{|code| code.match(/^orf/)},
  :native => 3
}

$lexicon = {
  :file => {
    :url => 'http://hypha.stanford.edu/download/chromosomal_feature_files/chromosomal_feature.tab',
    :native => 0,
    :extra => [8,1,2],
    :exclude => proc{|l| l.match(/^!/) && !l.match(/^orf/)}
  },
}

$identifiers = {
  :file => {
    :url => 'http://hypha.stanford.edu/download/chromosomal_feature_files/chromosomal_feature.tab',
    :native => 0,
    :extra => [8,1,2],
    :exclude => proc{|l| l.match(/^!/)},
    :fields => ["GCD ID", "Gene Name", "Gene Alias"]
  },
}

$go = {
  :url => "http://www.candidagenome.org/go/gene_association.cgd.gz",
  :code => 10,
  :go   => 4,
  :pmid => 5,
  :fix => proc{|l| v = l.split(/\t/); v[10] = (v[10] || "").split('|').first; v.join("\t")}
}

$query = '"candida albicans"[All Fields] AND ((("proteins"[TIAB] NOT Medline[SB]) OR "proteins"[MeSH Terms] OR protein[Text Word]) OR (("genes"[TIAB] NOT Medline[SB]) OR "genes"[MeSH Terms] OR gene[Text Word])) AND hasabstract[text] AND English[lang]'

####

#Rake::Task['identifiers'].clear
#file 'identifiers' => ['lexicon'] do |t|
#  identifiers = {}
#  if $identifiers[:file]
#    identifiers = Open.to_hash($identifiers[:file][:url], $identifiers[:file])
#  end
#
#  orf2native = Open.to_hash('lexicon', :native => 1, :extra => 0, :single => true)
#
#  translations = {}
#
#  Entrez.entrez2native(*$entrez2native.values_at(:tax,:native,:fix,:check)).each{|entrez, orfs|
#    orfs.each{|orf| 
#      translations[orf] ||= []
#      translations[orf] << entrez
#    }
#  }
#
#  orf2native.each{|orf, native|
#    next unless identifiers[native]
#    identifiers[native] << [orf]
#    if translations[orf]
#      identifiers[native] << translations[orf]
#    else
#      identifiers[native] << []
#    end
#
#  }
#
#  header = "#" + [$native_id, 'Gene Name', 'Orf',  "Entrez Gene ID"].uniq.join("\t") + "\n" 
#  Open.write('identifiers', 
#             header + 
#             identifiers.collect{|code, name_lists|
#               "#{ code }\t" + name_lists.collect{ |names| names.join("|") }.join("\t")
#             }.join("\n")
#            )
#end
#
#
