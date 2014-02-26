---
title: Knowledge Base Tutorial
layout: default
tagline: Knowledge Base
---

# Knowledge Bases in Rbbt

We will go bottom up in this section, starting with association databases and
index the building blocks. Knowledge bases fills a few gaps with the `Entity`
system to help automatize things.

## Association databases

An association database is nothing but a TSV. The key/first-field pair
specifies an association `source~target`, the rest of the fields qualify it.
The file can be of any type, but note that `:single` and `:flat` types will not
have qualifiers; type `:double` requires that the qualifiers fields and the
target field match. Usually the `key_field` and the first field are of known
`Entity` types, but it is not required.

### Trivial example

We begin by opening a TSV file as an association file. The
file we are opening is one that lists genes and their associated
GO terms. The file lists genes by their `Ensembl Gene ID`.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/association'
require 'rbbt/sources/organism'

assoc = Association.open(Organism.gene_go("Hsa/jan2013"))

gene = "ENSG00000146648"

puts "GO terms of #{gene}"
puts
assoc[gene].zip_fields.collect{|go, cat|
  puts [cat, go] * ": "
}

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
GO terms of ENSG00000146648

biological_process: GO:0006468
biological_process: GO:0007169
cellular_component: GO:0016021
cellular_component: GO:0016020
molecular_function: GO:0005524
molecular_function: GO:0004672
molecular_function: GO:0004713
molecular_function: GO:0016772
molecular_function: GO:0004714
molecular_function: GO:0004716
biological_process: GO:0008283
biological_process: GO:0007411
biological_process: GO:0043066
biological_process: GO:0000902
biological_process: GO:0008284
biological_process: GO:0007165
biological_process: GO:0048146
biological_process: GO:0000186
biological_process: GO:0016337
biological_process: GO:0048546
biological_process: GO:0006950
biological_process: GO:0007166
biological_process: GO:0030335
biological_process: GO:0045429
biological_process: GO:0001892
biological_process: GO:0043406
biological_process: GO:0050730
biological_process: GO:0051897
biological_process: GO:0046777
biological_process: GO:0001942
biological_process: GO:0007435
biological_process: GO:0045740
biological_process: GO:0001503
biological_process: GO:0050999
biological_process: GO:0050679
biological_process: GO:0051205
biological_process: GO:0007173
biological_process: GO:0000165
biological_process: GO:0021795
biological_process: GO:0042177
biological_process: GO:0007202
biological_process: GO:0060571
biological_process: GO:0045739
biological_process: GO:0042327
biological_process: GO:0042059
biological_process: GO:0031659
biological_process: GO:0035413
biological_process: GO:0043006
biological_process: GO:0070141
cellular_component: GO:0005634
cellular_component: GO:0005737
cellular_component: GO:0005886
cellular_component: GO:0005789
cellular_component: GO:0048471
cellular_component: GO:0000139
cellular_component: GO:0005615
cellular_component: GO:0016323
cellular_component: GO:0031965
cellular_component: GO:0010008
cellular_component: GO:0045121
cellular_component: GO:0005768
cellular_component: GO:0030139
cellular_component: GO:0030122
cellular_component: GO:0070435
molecular_function: GO:0005515
molecular_function: GO:0046982
molecular_function: GO:0003690
molecular_function: GO:0019899
molecular_function: GO:0051015
molecular_function: GO:0004888
molecular_function: GO:0042802
molecular_function: GO:0019903
molecular_function: GO:0004709
molecular_function: GO:0005006
molecular_function: GO:0030235
biological_process: GO:0042127
biological_process: GO:0008544
cellular_component: GO:0005622
molecular_function: GO:0004871
molecular_function: GO:0016301
</pre></dd></dl>

### Translating entities

So far this is no different than doing `TSV.open`; in fact, the result in this case
is the same, a TSV file. The `Association` module does more than just open the files, it
is aware of entities and their formats. Lets us try a different example, where the
association file is translated to use `Associated Gene Name`. For the translation to
work, Rbbt must be aware of the gene entity, which is defined in the `Genomics` workflow.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/association'
require 'rbbt/sources/organism'

require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'rbbt/entity/gene'

assoc = Association.open(Organism.gene_go("Hsa/jan2013"),
                         {:source_format => "Associated Gene Name"})

gene = "EGFR"

puts "Go terms of #{gene}"
puts
assoc[gene].zip_fields.collect{|go, cat|
  puts [cat, go] * ": "
}

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Go terms of EGFR

biological_process: GO:0006468
biological_process: GO:0007169
cellular_component: GO:0016021
cellular_component: GO:0016020
molecular_function: GO:0005524
molecular_function: GO:0004672
molecular_function: GO:0004713
molecular_function: GO:0016772
molecular_function: GO:0004714
molecular_function: GO:0004716
biological_process: GO:0008283
biological_process: GO:0007411
biological_process: GO:0043066
biological_process: GO:0000902
biological_process: GO:0008284
biological_process: GO:0007165
biological_process: GO:0048146
biological_process: GO:0000186
biological_process: GO:0016337
biological_process: GO:0048546
biological_process: GO:0006950
biological_process: GO:0007166
biological_process: GO:0030335
biological_process: GO:0045429
biological_process: GO:0001892
biological_process: GO:0043406
biological_process: GO:0050730
biological_process: GO:0051897
biological_process: GO:0046777
biological_process: GO:0001942
biological_process: GO:0007435
biological_process: GO:0045740
biological_process: GO:0001503
biological_process: GO:0050999
biological_process: GO:0050679
biological_process: GO:0051205
biological_process: GO:0007173
biological_process: GO:0000165
biological_process: GO:0021795
biological_process: GO:0042177
biological_process: GO:0007202
biological_process: GO:0060571
biological_process: GO:0045739
biological_process: GO:0042327
biological_process: GO:0042059
biological_process: GO:0031659
biological_process: GO:0035413
biological_process: GO:0043006
biological_process: GO:0070141
cellular_component: GO:0005634
cellular_component: GO:0005737
cellular_component: GO:0005886
cellular_component: GO:0005789
cellular_component: GO:0048471
cellular_component: GO:0000139
cellular_component: GO:0005615
cellular_component: GO:0016323
cellular_component: GO:0031965
cellular_component: GO:0010008
cellular_component: GO:0045121
cellular_component: GO:0005768
cellular_component: GO:0030139
cellular_component: GO:0030122
cellular_component: GO:0070435
molecular_function: GO:0005515
molecular_function: GO:0046982
molecular_function: GO:0003690
molecular_function: GO:0019899
molecular_function: GO:0051015
molecular_function: GO:0004888
molecular_function: GO:0042802
molecular_function: GO:0019903
molecular_function: GO:0004709
molecular_function: GO:0005006
molecular_function: GO:0030235
biological_process: GO:0042127
biological_process: GO:0008544
cellular_component: GO:0005622
molecular_function: GO:0004871
molecular_function: GO:0016301
</pre></dd></dl>

Just a reminder: make the system aware of GO terms to list their descriptions.
GO term entities are defined in their `rbbt/sources` file.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/association'
require 'rbbt/sources/organism'

require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'rbbt/entity/gene'
require 'rbbt/sources/go'

assoc = Association.open(Organism.gene_go("Hsa/jan2013"),
                         {:source_format => "Associated Gene Name"})

gene = "EGFR"

puts "GO terms of #{gene}"
puts
assoc[gene].zip_fields.collect{|values|
  # The short hand version used before does not setup the entities.
  # Using values_at does
  go, cat = values.values_at 0, 1
  puts [cat, go.name] * ": "
}

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
GO terms of EGFR

biological_process: protein phosphorylation
biological_process: transmembrane receptor protein tyrosine kinase signaling pathway
cellular_component: integral to membrane
cellular_component: membrane
molecular_function: ATP binding
molecular_function: protein kinase activity
molecular_function: protein tyrosine kinase activity
molecular_function: transferase activity, transferring phosphorus-containing groups
molecular_function: transmembrane receptor protein tyrosine kinase activity
molecular_function: receptor signaling protein tyrosine kinase activity
biological_process: cell proliferation
biological_process: axon guidance
biological_process: negative regulation of apoptotic process
biological_process: cell morphogenesis
biological_process: positive regulation of cell proliferation
biological_process: signal transduction
biological_process: positive regulation of fibroblast proliferation
biological_process: activation of MAPKK activity
biological_process: cell-cell adhesion
biological_process: digestive tract morphogenesis
biological_process: response to stress
biological_process: cell surface receptor signaling pathway
biological_process: positive regulation of cell migration
biological_process: positive regulation of nitric oxide biosynthetic process
biological_process: embryonic placenta development
biological_process: positive regulation of MAP kinase activity
biological_process: regulation of peptidyl-tyrosine phosphorylation
biological_process: positive regulation of protein kinase B signaling cascade
biological_process: protein autophosphorylation
biological_process: hair follicle development
biological_process: salivary gland morphogenesis
biological_process: positive regulation of DNA replication
biological_process: ossification
biological_process: regulation of nitric-oxide synthase activity
biological_process: positive regulation of epithelial cell proliferation
biological_process: protein insertion into membrane
biological_process: epidermal growth factor receptor signaling pathway
biological_process: MAPK cascade
biological_process: cerebral cortex cell migration
biological_process: negative regulation of protein catabolic process
biological_process: activation of phospholipase C activity
biological_process: morphogenesis of an epithelial fold
biological_process: positive regulation of DNA repair
biological_process: positive regulation of phosphorylation
biological_process: negative regulation of epidermal growth factor receptor signaling pathway
biological_process: positive regulation of cyclin-dependent protein serine/threonine kinase activity involved in G1/S
biological_process: positive regulation of catenin import into nucleus
biological_process: activation of phospholipase A2 activity by calcium-mediated signaling
biological_process: response to UV-A
cellular_component: nucleus
cellular_component: cytoplasm
cellular_component: plasma membrane
cellular_component: endoplasmic reticulum membrane
cellular_component: perinuclear region of cytoplasm
cellular_component: Golgi membrane
cellular_component: extracellular space
cellular_component: basolateral plasma membrane
cellular_component: nuclear membrane
cellular_component: endosome membrane
cellular_component: membrane raft
cellular_component: endosome
cellular_component: endocytic vesicle
cellular_component: AP-2 adaptor complex
cellular_component: Shc-EGFR complex
molecular_function: protein binding
molecular_function: protein heterodimerization activity
molecular_function: double-stranded DNA binding
molecular_function: enzyme binding
molecular_function: actin filament binding
molecular_function: transmembrane signaling receptor activity
molecular_function: identical protein binding
molecular_function: protein phosphatase binding
molecular_function: MAP kinase kinase kinase activity
molecular_function: epidermal growth factor-activated receptor activity
molecular_function: nitric-oxide synthase regulator activity
biological_process: regulation of cell proliferation
biological_process: epidermis development
cellular_component: intracellular
molecular_function: signal transducer activity
molecular_function: kinase activity
</pre></dd></dl>


### ICGC Example

The same functionalities to specify sources and targets are available when
creating indexes. As our next example shows. Note how we do `:persist` the
database, otherwise we could not use Tokyocabinet's B-tree range search; this
is the default, anyway. Note also the performance benchmark, a million queries
in 10 seconds i.e. 100K queries/second.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/association'
require 'rbbt/sources/organism'

require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'rbbt/entity/gene'


assoc = Association.index('ftp://data.dcc.icgc.org/current/Chronic_Lymphocytic_Leukemia-ISC_MICINN-ES/simple_somatic_mutation.CLLE-ES.tsv.gz',
                         { :source => "gene_affected=~Ensembl Gene ID=>Associated Gene Name", 
                           :target => "icgc_donor_id=~Sample", 
                           :fields => ['consequence_type'],  
                           :namespace => 'Hsa/jan2013',
                           :merge => true, :header_hash=>''}, :persist => true)


puts "Associations: ", assoc.match("SF3B1") * ", "

Misc.benchmark(1_000_000) do
  assoc.match("SF3B1") 
end

Misc.profile do
Misc.benchmark(1_000) do
assoc.match("SF3B1") 
end
end
{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Associations: 
SF3B1~DO6376, SF3B1~DO6392, SF3B1~DO6426, SF3B1~DO6436, SF3B1~DO6468, SF3B1~DO6494, SF3B1~DO6525, SF3B1~DO6898, SF3B1~DO7000
Benchmark for 1000000 repeats
 12.530000   0.000000  12.530000 ( 12.532505)
</pre></dd></dl>

## Knowledge Bases

We are ready to put all this together into a knowledge base. 

### First example

Here we create a knowledge base, on a temporary directory, with namespace
`Hsa/jan2013`, and register the Pina protein-protein interaction database. We
need to specify that the target field `Interactor UniProt/SwissProt Accession`
should be interpreted as `UniProt/SwissProt Accession`. We have also specify that 
the preferred format for `Gene` entities is `Associated Gene Name`. 

The `children` method retrieves the matches from the database, annotated as
`AssociationItem` entities. This means we can easily extract the `target`,
and we can also extract the `target_entity`, which are annotated as their appropriate
entities; which can be viewed in this example when we use the `Gene` entity method `ensembl`
to translate them to `Ensembl Gene ID`. Of course, every new layer add some overhead.

Registering a database does not start its processing. Loading the databases,
indices, etc. is done on-demand. Once they are setup the first time, they will
be reused, as usual. Finally, note how the database is registered as
`undirected`, which includes the converse of each interaction to the index.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/knowledge_base'
require 'rbbt/util/tmpfile'
require 'rbbt/sources/organism'

require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'rbbt/entity/gene'
require 'rbbt/sources/pina'

TmpFile.with_dir do |dir|
  kb = KnowledgeBase.new dir, "Hsa/jan2013"
  kb.format["Gene"] = "Associated Gene Name"

  kb.register :pina, Pina.protein_protein, 
    :target => "Interactor UniProt/SwissProt Accession=~UniProt/SwissProt Accession",
    :undirected => true

  gene = "SF3B1"

  puts "Matches: ", kb.children(:pina, gene) * ", "
  puts "Targets: ", kb.children(:pina, gene).target * ", "
  puts "Ensembl: ", kb.children(:pina, gene).target_entity.ensembl * ", "

  puts

  Misc.benchmark(10_000) do
    kb.indices[:pina].match(gene)
  end

  Misc.benchmark(10_000) do
    kb.children(:pina, gene)
  end

  Misc.benchmark(10_000) do
    kb.children(:pina, gene).target
  end

  Misc.benchmark(10_000) do
    kb.children(:pina, gene).target_entity
  end
end

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Matches: 
SF3B1~APBB1, SF3B1~ARF6, SF3B1~ARPC2, SF3B1~ATG12, SF3B1~BAZ1B, SF3B1~BRF2, SF3B1~CCNE1, SF3B1~CDC5L, SF3B1~CFLAR, SF3B1~DDX42, SF3B1~DYRK1A, SF3B1~GSK3B, SF3B1~H3F3B, SF3B1~HDAC3, SF3B1~IKBKE, SF3B1~MELK, SF3B1~MYC, SF3B1~PHF5A, SF3B1~PPP1R8, SF3B1~PRPF40A, SF3B1~PUF60, SF3B1~RBM17, SF3B1~RNPS1, SF3B1~SAP130, SF3B1~SF3A2, SF3B1~SF3B14, SF3B1~SF3B3, SF3B1~SF3B4, SF3B1~SF3B5, SF3B1~SMAD1, SF3B1~SMAD5, SF3B1~SMAD9, SF3B1~SMNDC1, SF3B1~SNIP1, SF3B1~SNRNP40, SF3B1~SNRPN, SF3B1~TCERG1, SF3B1~TOPORS, SF3B1~WBP4, SF3B1~WWOX, SF3B1~YWHAG, SF3B1~YWHAZ
Targets: 
APBB1, ARF6, ARPC2, ATG12, BAZ1B, BRF2, CCNE1, CDC5L, CFLAR, DDX42, DYRK1A, GSK3B, H3F3B, HDAC3, IKBKE, MELK, MYC, PHF5A, PPP1R8, PRPF40A, PUF60, RBM17, RNPS1, SAP130, SF3A2, SF3B14, SF3B3, SF3B4, SF3B5, SMAD1, SMAD5, SMAD9, SMNDC1, SNIP1, SNRNP40, SNRPN, TCERG1, TOPORS, WBP4, WWOX, YWHAG, YWHAZ
Ensembl: 
ENSG00000166313, ENSG00000165527, ENSG00000163466, ENSG00000145782, ENSG00000009954, ENSG00000104221, ENSG00000105173, ENSG00000096401, ENSG00000003402, ENSG00000198231, ENSG00000157540, ENSG00000082701, ENSG00000132475, ENSG00000171720, ENSG00000143466, ENSG00000165304, ENSG00000136997, ENSG00000100410, ENSG00000117751, ENSG00000196504, ENSG00000179950, ENSG00000134453, ENSG00000205937, ENSG00000136715, ENSG00000104897, ENSG00000115128, ENSG00000189091, ENSG00000143368, ENSG00000169976, ENSG00000170365, ENSG00000113658, ENSG00000120693, ENSG00000119953, ENSG00000163877, ENSG00000060688, ENSG00000128739, ENSG00000113649, ENSG00000197579, ENSG00000120688, ENSG00000186153, ENSG00000170027, ENSG00000164924

Benchmark for 10000 repeats
  0.230000   0.010000   0.240000 (  0.248403)
Benchmark for 10000 repeats
  0.870000   0.000000   0.870000 (  0.865072)
Benchmark for 10000 repeats
  1.470000   0.000000   1.470000 (  1.472894)
Benchmark for 10000 repeats
  3.010000   0.000000   3.010000 (  3.017540)
</pre></dd></dl>

We can also use the `version` method to do this automatically. It will create
a subdirectory in the knowledge base directory with the new namespace, create
a new knowledge base for it and copy the registry

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/knowledge_base'
require 'rbbt/util/tmpfile'
require 'rbbt/sources/organism'

require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'genomics_kb'

namespace = "Hsa/may2009"
gene = "TP53"

puts "Organism (namespace) of interactors of #{gene} in the global Genomics KB"
found = Genomics.knowledge_base.identify :pina, gene
puts Genomics.knowledge_base.children(:pina, found).target_entity.organism 

kb = Genomics.knowledge_base.version namespace

puts
puts "Organism (namespace) interactors of #{gene} in #{namespace} global KB"
found = kb.identify :pina, gene
puts kb.children(:pina, found).target_entity.organism 

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Organism (namespace) of interactors of TP53 in the global Genomics KB
Hsa/jan2013

Organism (namespace) interactors of TP53 in Hsa/may2009 global KB
Hsa/may2009
</pre></dd></dl>

### Qualifying associations

The following example shows how to access they values that qualify each association. The 
`values` proerty of `AssociationItem` entities returns a `NamedArray` with the qualification 
values associated with their corresponding field names.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/knowledge_base'
require 'rbbt/util/tmpfile'
require 'rbbt/sources/organism'

require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'genomics_kb'

gene = "TP53"
puts "Interactors of #{gene}, with qualifiers"
found = Genomics.knowledge_base.identify :pina, gene
Genomics.knowledge_base.children(:pina, found).each do |match|
  puts
  puts match.target_entity.name << ": "
  puts "Method= " << match.values["Method"]
  puts "PMID= " << match.values["PMID"]
  
end

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Interactors of TP53, with qualifiers

NFYA: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0004;;MI:0006;;MI:0493;;MI:0006;;MI:0006;;MI:0004;;MI:0004
PMID= 16959611;;16959611;;16959611;;16959611;;16959611;;16959611;;16959611;;16959611;;16959611;;15831478;;16959611;;16959611;;16959611;;16959611;;15831478;;15831478

CFLAR: 
Method= MI:0004;;MI:0004
PMID= 18559494;;18559494

KDM1A: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004
PMID= 17805299;;17805299;;17805299;;17805299;;17805299;;18573881;;18573881

DVL2: 
Method= MI:0018;;MI:0018;;MI:0018;;MI:0398;;MI:0096;;MI:0018;;MI:0096;;MI:0096
PMID= 16189514;;16189514;;16189514;;16189514;;16713569;;16189514;;16713569;;16713569

CREBBP: 
Method= MI:0006;;MI:0055;;MI:0493;;MI:0096;;MI:0401;;MI:0096;;MI:0096;;MI:0096;;MI:0006;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0428;;MI:0006;;MI:0006;;MI:0415;;MI:0096;;MI:0096;;MI:0415;;MI:0004;;MI:0004;;MI:0096;;MI:0415;;MI:0096;;MI:0006
PMID= 9194564;;19166313;;11782467;;10848610;;10823891;;11782467;;14722092;;10196247;;9194564;;11782467;;10196247;;9288775;;9288775;;15632413;;9194564;;9194564;;19805293;;10196247;;10196247;;21390126;;12426395;;16537920;;9194564;;18485870;;9194564;;9194564

MLL5: 
Method= MI:0004
PMID= 21423215

CCL18: 
Method= MI:0018;;MI:0018;;MI:0492;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

IFRD1: 
Method= MI:0004;;MI:0004
PMID= 17130840;;17130840

BTK: 
Method= MI:0492
PMID= 15355990

BRCA1: 
Method= MI:0493;;MI:0401;;MI:0096;;MI:0401;;MI:0096;;MI:0019;;MI:0096;;MI:0004;;MI:0401;;MI:0004
PMID= 9482880;;14636569;;9582019;;14636569;;9926942;;9482880;;9926942;;9482880;;14636569;;14710355

CAPN1: 
Method= MI:0493
PMID= 12432277

ZMYND11: 
Method= MI:0004
PMID= 17721438

MNAT1: 
Method= MI:0492;;MI:0415;;MI:0415;;MI:0493
PMID= 9372954;;9372954;;9372954;;9840937

VRK2: 
Method= MI:0415;;MI:0415
PMID= 16704422;;16704422

BAK1: 
Method= MI:0004;;MI:0004;;MI:0493;;MI:0004
PMID= 15077116;;15077116;;15077116;;15077116

PIAS1: 
Method= MI:0018;;MI:0018;;MI:0018;;MI:0492;;MI:0096;;MI:0096;;MI:0096;;MI:0096
PMID= 10380882;;11583632;;11583632;;15133049;;15133049;;15133049;;15133049;;11867732

RFC1: 
Method= MI:0004
PMID= 12509469

MED17: 
Method= MI:0004;;MI:0492
PMID= 10198638;;10198638

CUL7: 
Method= MI:0004;;MI:0077;;MI:0004;;MI:0004;;MI:0077;;MI:0077
PMID= 16547496;;17298945;;16547496;;16547496;;17298945;;17298945

EPHA3: 
Method= MI:0492;;MI:0096
PMID= 15355990;;15355990

HSPA5: 
Method= MI:0493;;MI:0006;;MI:0006
PMID= 17184779;;17184779;;17184779

RRM2B: 
Method= MI:0424;;MI:0424;;MI:0004;;MI:0493;;MI:0019
PMID= 19015526;;19015526;;12615712;;12615712;;12615712

MAPK9: 
Method= MI:0415;;MI:0004;;MI:0493
PMID= 9393873;;12384512;;9393873

RAD51: 
Method= MI:0493;;MI:0019;;MI:0019;;MI:0096;;MI:0096;;MI:0401;;MI:0004;;MI:0401;;MI:0096;;MI:0401;;MI:0493
PMID= 15064730;;9380510;;9380510;;8617246;;8617246;;14636569;;16983346;;14636569;;9380510;;14636569;;9380510

EIF2AK2: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0493;;MI:0004;;MI:0004
PMID= 10348343;;10348343;;10348343;;10348343;;10348343;;10348343

RASGRF1: 
Method= MI:0006;;MI:0006
PMID= 16753148;;16753148

CCAR1: 
Method= MI:0004
PMID= 18382127

CA11: 
Method= MI:0004
PMID= 18382127

HIPK2: 
Method= MI:0493;;MI:0096;;MI:0096;;MI:0018;;MI:0006;;MI:0096;;MI:0006;;MI:0096;;MI:0493;;MI:0096;;MI:0096
PMID= 16343438;;16212962;;11740489;;11925430;;15896780;;16212962;;15896780;;11740489;;11925430;;11740489;;11740489

YBX1: 
Method= MI:0493;;MI:0004;;MI:0096;;MI:0096
PMID= 11175333;;15136035;;11175333;;11175333

SMARCD1: 
Method= MI:0018;;MI:0018
PMID= 18303029;;18303029

ASPM: 
Method= MI:0004
PMID= 20308539

TRMT11: 
Method= MI:0004
PMID= 20308539

KLF6: 
Method= MI:0493
PMID= 15131018

TP53BP1: 
Method= MI:0114;;MI:0018;;MI:0114;;MI:0096;;MI:0004;;MI:0492;;MI:0018;;MI:0096;;MI:0004;;MI:0018;;MI:0114;;MI:0114;;MI:0004;;MI:0492
PMID= 11877378;;8016121;;12351827;;14978302;;15611139;;12110597;;8016121;;11877378;;15364958;;8016121;;11877378;;12110597;;15364958;;15364958

OTUD5: 
Method= MI:0007;;MI:0004
PMID= 19615732;;19615732

CDC42: 
Method= MI:0018;;MI:0492;;MI:0398
PMID= 16169070;;16169070;;16169070

XRCC1: 
Method= MI:0004;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096
PMID= 15044383;;15044383;;15044383;;15044383;;15044383;;15044383;;15044383

TP63: 
Method= MI:0006;;MI:0493;;MI:0006;;MI:0006;;MI:0006
PMID= 19345189;;11238924;;19345189;;19345189;;19345189

PTGS2: 
Method= MI:0493;;MI:0004
PMID= 11687965;;11687965

TSG101: 
Method= MI:0004;;MI:0493;;MI:0004
PMID= 11172000;;11172000;;11172000

TOP2B: 
Method= MI:0004;;MI:0493;;MI:0004
PMID= 10666337;;10666337;;10666337

UBE2A: 
Method= MI:0004;;MI:0416;;MI:0004;;MI:0493
PMID= 12640129;;12640129;;12640129;;12640129

PIAS2: 
Method= MI:0096;;MI:0018;;MI:0018;;MI:0096;;MI:0663
PMID= 11867732;;19901969;;19901969;;11867732;;18624398

UBE2K: 
Method= MI:0493
PMID= 10634809

PPP2R5C: 
Method= MI:0006;;MI:0006
PMID= 17245430;;17245430

ITCH: 
Method= MI:0004
PMID= 18559494

TP73: 
Method= MI:0493
PMID= 11238924

CDC14A: 
Method= MI:0018;;MI:0018;;MI:0493;;MI:0018
PMID= 10644693;;10644693;;10644693;;10644693

PAFAH1B3: 
Method= MI:0492;;MI:0018;;MI:0398;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

HSP90AA1: 
Method= MI:0493;;MI:0004;;MI:0004;;MI:0004
PMID= 11507088;;11507088;;12427754;;11297531

CDC14B: 
Method= MI:0018;;MI:0018;;MI:0493
PMID= 10644693;;10644693;;10644693

GSK3B: 
Method= MI:0027;;MI:0493;;MI:0027;;MI:0027;;MI:0004;;MI:0027;;MI:0004
PMID= 14744935;;12048243;;14744935;;14744935;;12048243;;14744935;;12048243

XPO1: 
Method= MI:0006;;MI:0006;;MI:0006
PMID= 17268548;;18952844;;17268548

KAT6A: 
Method= MI:0004;;MI:0004;;MI:0004
PMID= 19001415;;19001415;;19001415

TAF9: 
Method= MI:0096;;MI:0004
PMID= 7761466;;18250150

HUWE1: 
Method= MI:0007;;MI:0007;;MI:0492;;MI:0007
PMID= 15989956;;15989956;;15989956;;15989956

TFAP2C: 
Method= MI:0493;;MI:0428
PMID= 12226108;;12226108

AURKA: 
Method= MI:0018;;MI:0492;;MI:0018;;MI:0096;;MI:0096;;MI:0096;;MI:0018;;MI:0018;;MI:0018;;MI:0096
PMID= 12198151;;12198151;;12198151;;14702041;;14702041;;14702041;;12198151;;12198151;;12198151;;14702041

MAPKAPK5: 
Method= MI:0424;;MI:0424;;MI:0424;;MI:0492;;MI:0424
PMID= 17254968;;17254968;;17254968;;17254968;;17254968

APOH: 
Method= MI:0663
PMID= 18624398

ESR1: 
Method= MI:0492;;MI:0096
PMID= 10766163;;10766163

EIF2C1: 
Method= MI:0004
PMID= 20308539

MSH2: 
Method= MI:0004;;MI:0004;;MI:0493
PMID= 12101417;;12101417;;15064730

HSP90AB1: 
Method= MI:0493
PMID= 11707401

SIRT1: 
Method= MI:0493;;MI:0004
PMID= 11672523;;18235502

ABL1: 
Method= MI:0493;;MI:0096
PMID= 10713716;;10629029

SMARCB1: 
Method= MI:0096;;MI:0096;;MI:0096;;MI:0493;;MI:0096
PMID= 11950834;;11950834;;11950834;;11950834;;11950834

MAPK1: 
Method= MI:0493;;MI:0004
PMID= 11409876;;10958792

EP300: 
Method= MI:0096;;MI:0493;;MI:0415;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0415;;MI:0004;;MI:0006;;MI:0004;;MI:0096;;MI:0006;;MI:0415;;MI:0006;;MI:0004;;MI:0096;;MI:0004;;MI:0071;;MI:0006;;MI:0415;;MI:0004;;MI:0019;;MI:0004;;MI:0006;;MI:0096;;MI:0019;;MI:0006;;MI:0004;;MI:0493;;MI:0006
PMID= 9809062;;16438982;;18485870;;11907332;;15186775;;11782467;;9809062;;9809062;;11782467;;18485870;;15542844;;10518217;;16024799;;11907332;;15542844;;19805293;;16782091;;17452980;;9809062;;16537920;;11070080;;10.1038/emboj.2009.83;;18485870;;16678111;;16611888;;18612383;;10.1038/emboj.2009.83;;15295102;;16611888;;16782091;;17977830;;16782091;;9194564

FKBP3: 
Method= MI:0096
PMID= 19166840

ERH: 
Method= MI:0492;;MI:0398;;MI:0018;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

HIF1A: 
Method= MI:0004;;MI:0096;;MI:0004;;MI:0004;;MI:0492;;MI:0096
PMID= 10640274;;12606552;;9537326;;9537326;;12124396;;12124396

VRK1: 
Method= MI:0004;;MI:0415;;MI:0006;;MI:0493;;MI:0004;;MI:0004
PMID= 15542844;;10951572;;15542844;;10747897;;15542844;;15542844

YY1: 
Method= MI:0401;;MI:0096;;MI:0096;;MI:0004;;MI:0004;;MI:0004
PMID= 18026119;;15295102;;15295102;;15210108;;15210108;;15210108

APEX1: 
Method= MI:0493;;MI:0401
PMID= 9119221;;9119221

CHD8: 
Method= MI:0004
PMID= 19151705

NFKBIA: 
Method= MI:0004;;MI:0004;;MI:0493
PMID= 11799106;;11799106;;11799106

HNF4A: 
Method= MI:0096;;MI:0492
PMID= 11818510;;11818510

STK4: 
Method= MI:0493
PMID= 12384512

CSNK2A1: 
Method= MI:0493
PMID= 10747897

MYL9: 
Method= MI:0004
PMID= 20308539

E2F1: 
Method= MI:0493
PMID= 11739724

PSMD10: 
Method= MI:0004
PMID= 16023600

POLA1: 
Method= MI:0004;;MI:0493
PMID= 11917009;;11917009

BMX: 
Method= MI:0006;;MI:0006;;MI:0006
PMID= 16186805;;16186805;;16186805

USP11: 
Method= MI:0004;;MI:0007
PMID= 19615732;;19615732

CD40LG: 
Method= MI:0493
PMID= 12011072

MAPK3: 
Method= MI:0493;;MI:0004
PMID= 10958792;;10958792

NPRL3: 
Method= MI:0004
PMID= 20308539

TAF1C: 
Method= MI:0492;;MI:0096
PMID= 10913176;;10913176

MTHFSD: 
Method= MI:0004
PMID= 20308539

FAM173A: 
Method= MI:0492;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070

STUB1: 
Method= MI:0004
PMID= 18223694

UBE2I: 
Method= MI:0007;;MI:0007;;MI:0415;;MI:0018;;MI:0018;;MI:0018;;MI:0018;;MI:0663;;MI:0018;;MI:0007;;MI:0007
PMID= 15327968;;15327968;;11853669;;8921390;;10961991;;10380882;;8921390;;18624398;;8921390;;15327968;;15327968

KAT8: 
Method= MI:0006;;MI:0415;;MI:0004;;MI:0004;;MI:0006
PMID= 16601686;;17189187;;19854137;;15960975;;16601686

IKBKB: 
Method= MI:0006;;MI:0006
PMID= 19883646;;19883646

PPP1R13L: 
Method= MI:0065;;MI:0004;;MI:0492
PMID= 18275817;;12524540;;12524540

ERCC2: 
Method= MI:0096
PMID= 7663514

PIAS4: 
Method= MI:0018;;MI:0018;;MI:0018
PMID= 15383276;;11388671;;11388671

HNRNPUL1: 
Method= MI:0493;;MI:0096;;MI:0006;;MI:0006;;MI:0096;;MI:0006;;MI:0096;;MI:0096;;MI:0096;;MI:0006;;MI:0006;;MI:0096;;MI:0096;;MI:0006;;MI:0096;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0006;;MI:0096;;MI:0096
PMID= 15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477;;15907477

PPP2R1A: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 17245430;;17245430;;17245430;;17245430

ELL: 
Method= MI:0493;;MI:0018;;MI:0018;;MI:0018;;MI:0018;;MI:0018
PMID= 10358050;;10358050;;10358050;;10358050;;10358050;;10358050

ETHE1: 
Method= MI:0004;;MI:0004
PMID= 17353187;;17353187

DNAJB6: 
Method= MI:0004
PMID= 20308539

HSPB1: 
Method= MI:0018;;MI:0492;;MI:0398;;MI:0018;;MI:0006;;MI:0006;;MI:0018;;MI:0493
PMID= 16169070;;16169070;;16169070;;16169070;;17184779;;17184779;;16169070;;17184779

TAF6: 
Method= MI:0096;;MI:0071;;MI:0096;;MI:0096
PMID= 20096117;;7809597;;20096117;;20096117

AIMP2: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0006;;MI:0006
PMID= 18695251;;18695251;;18695251;;18695251;;18695251;;18695251

ZNHIT1: 
Method= MI:0492
PMID= 17380123

BAG1: 
Method= MI:0096
PMID= 9582267

MAPK8: 
Method= MI:0493;;MI:0006;;MI:0096;;MI:0096;;MI:0006;;MI:0415;;MI:0493
PMID= 15580310;;15580310;;15538975;;15538975;;15580310;;9393873;;9732264

GTPBP4: 
Method= MI:0004
PMID= 20308539

ZMIZ1: 
Method= MI:0018;;MI:0018;;MI:0018
PMID= 17584785;;17584785;;17584785

TADA2A: 
Method= MI:0004
PMID= 18250150

KPNB1: 
Method= MI:0004;;MI:0004;;MI:0493
PMID= 11297531;;11297531;;11297531

SMARCD2: 
Method= MI:0004
PMID= 20308539

DDX5: 
Method= MI:0493
PMID= 15660129

PSMD11: 
Method= MI:0492;;MI:0018;;MI:0018;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

KAT2A: 
Method= MI:0004
PMID= 18250150

YWHAE: 
Method= MI:0053;;MI:0053;;MI:0053;;MI:0053;;MI:0053;;MI:0053
PMID= 18812399;;18812399;;18812399;;18812399;;18812399;;18812399

DPH1: 
Method= MI:0004
PMID= 20308539

SULT1E1: 
Method= MI:0018;;MI:0492;;MI:0398;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

MAPK10: 
Method= MI:0415;;MI:0493
PMID= 9393873;;9393873

HSPA8: 
Method= MI:0004
PMID= 11297531

HIPK3: 
Method= MI:0018
PMID= 10961991

GTF2H1: 
Method= MI:0077;;MI:0077;;MI:0096;;MI:0077;;MI:0077;;MI:0492;;MI:0077;;MI:0077;;MI:0077;;MI:0077;;MI:0077;;MI:0077
PMID= 18354501;;18354501;;7935417;;18354501;;18354501;;7935417;;18354501;;18354501;;18354501;;18354501;;18354501;;18354501

VDR: 
Method= MI:0416;;MI:0416;;MI:0416;;MI:0416;;MI:0416
PMID= 20227041;;20227041;;20227041;;20227041;;20227041

COPS7A: 
Method= MI:0492;;MI:0492
PMID= 11285227;;11285227

ING4: 
Method= MI:0019;;MI:0004;;MI:0493;;MI:0004;;MI:0019;;MI:0004;;MI:0004;;MI:0004;;MI:0004
PMID= 15251430;;12750254;;12750254;;15882981;;15251430;;18775696;;15882981;;17954561;;12750254

ASF1A: 
Method= MI:0004
PMID= 20308539

PHF1: 
Method= MI:0004;;MI:0004
PMID= 18385154;;18385154

TBP: 
Method= MI:0047;;MI:0004;;MI:0047;;MI:0096;;MI:0004;;MI:0096;;MI:0096;;MI:0492
PMID= 7799929;;11313951;;7799929;;1465435;;10359315;;9349482;;9349482;;1465435

CUL9: 
Method= MI:0018;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0492;;MI:0004;;MI:0018;;MI:0004
PMID= 18230339;;12526791;;12526791;;12526791;;12526791;;12526791;;12526791;;18230339;;17380154

LAMA4: 
Method= MI:0018;;MI:0492;;MI:0398
PMID= 16169070;;16169070;;16169070

BRD8: 
Method= MI:0004
PMID= 20308539

HSPA9: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0006;;MI:0004;;MI:0004;;MI:0096;;MI:0096;;MI:0493;;MI:0006;;MI:0004;;MI:0493
PMID= 20153329;;20153329;;20153329;;17184779;;20153329;;20153329;;11900485;;11900485;;11900485;;17184779;;20153329;;17184779

CCNG1: 
Method= MI:0004;;MI:0493;;MI:0096;;MI:0096
PMID= 12642871;;12556559;;12556559;;12556559

PPP2CA: 
Method= MI:0493
PMID= 12556559

NR3C1: 
Method= MI:0493;;MI:0004;;MI:0096;;MI:0096;;MI:0096;;MI:0493
PMID= 11080152;;11080152;;11562347;;11562347;;11562347;;11562347

CSNK1A1: 
Method= MI:0492
PMID= 9765199

UBE3A: 
Method= MI:0107;;MI:0107;;MI:0096;;MI:0096;;MI:0493
PMID= 16493710;;16493710;;12620801;;12620801;;9369221

KAT2B: 
Method= MI:0006;;MI:0006;;MI:0004;;MI:0415;;MI:0004;;MI:0018;;MI:0004
PMID= 16959611;;16959611;;16678111;;12068014;;16537920;;9744860;;17977830

WDR48: 
Method= MI:0004;;MI:0007
PMID= 19615732;;19615732

NCL: 
Method= MI:0493;;MI:0004;;MI:0004;;MI:0004
PMID= 12138209;;12138209;;12138209;;12138209

TAF1B: 
Method= MI:0096;;MI:0492
PMID= 10913176;;10913176

CEBPZ: 
Method= MI:0493;;MI:0006;;MI:0006;;MI:0004;;MI:0006;;MI:0006;;MI:0004
PMID= 12534345;;12534345;;12534345;;12534345;;12534345;;12534345;;12534345

ARID3A: 
Method= MI:0493
PMID= 12136662

SUMO1: 
Method= MI:0492;;MI:0004;;MI:0808;;MI:0096;;MI:0096;;MI:0018;;MI:0004
PMID= 15931224;;12917636;;16732283;;11867732;;18583933;;10961991;;17369817

DHCR24: 
Method= MI:0493
PMID= 15577914

HDAC1: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0004;;MI:0006;;MI:0004;;MI:0004;;MI:0006;;MI:0096;;MI:0096;;MI:0493;;MI:0006;;MI:0096;;MI:0004;;MI:0006;;MI:0004;;MI:0004;;MI:0006;;MI:0004;;MI:0096;;MI:0004;;MI:0004;;MI:0006;;MI:0004
PMID= 16959611;;16959611;;10.1038/emboj.2009.395;;18765668;;10.1038/emboj.2009.395;;14976551;;16697957;;10.1038/emboj.2009.395;;10777477;;10777477;;10777477;;10.1038/emboj.2009.395;;11099047;;16107876;;16959611;;10521394;;17827154;;10.1038/emboj.2009.395;;19011633;;10777477;;11313951;;11313951;;10.1038/emboj.2009.395;;12426395

RBBP5: 
Method= MI:0004
PMID= 15960975

CR2: 
Method= MI:0492
PMID= 7753047

STK11: 
Method= MI:0493;;MI:0004
PMID= 11430832;;11430832

MLL: 
Method= MI:0004
PMID= 15960975

CREB1: 
Method= MI:0096;;MI:0096;;MI:0096
PMID= 10848610;;10848610;;10848610

PLAGL1: 
Method= MI:0492;;MI:0096;;MI:0096
PMID= 11360197;;11360197;;11360197

TTLL5: 
Method= MI:0004
PMID= 20308539

SUPT7L: 
Method= MI:0004
PMID= 18250150

KANSL1: 
Method= MI:0004
PMID= 19854137

EGR1: 
Method= MI:0027;;MI:0027;;MI:0004;;MI:0004;;MI:0492
PMID= 14744935;;14744935;;11251186;;11251186;;11251186

NFYB: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0493;;MI:0004
PMID= 16959611;;16959611;;16959611;;16959611;;16959611;;16959611;;15831478

COPS5: 
Method= MI:0492;;MI:0004;;MI:0492;;MI:0004;;MI:0004;;MI:0004
PMID= 11285227;;16936264;;11285227;;17879958;;17879958;;17879958

RPL5: 
Method= MI:0493;;MI:0004;;MI:0004
PMID= 7935455;;15308643;;15308643

ZMIZ2: 
Method= MI:0018
PMID= 17584785

KIAA0087: 
Method= MI:0018;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070

CDKN2C: 
Method= MI:0018;;MI:0018;;MI:0398;;MI:0492;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

NR4A1: 
Method= MI:0493;;MI:0493;;MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0004;;MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0004;;MI:0007;;MI:0493;;MI:0004;;MI:0007
PMID= 17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261;;17139261

CDK2: 
Method= MI:0493;;MI:0415
PMID= 10884347;;10884347

EIF2C2: 
Method= MI:0004
PMID= 20308539

CSE1L: 
Method= MI:0030;;MI:0030;;MI:0030;;MI:0030;;MI:0030
PMID= 17719542;;17719542;;17719542;;17719542;;17719542

SNAI1: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 20385133;;20385133;;20385133;;20385133

NQO2: 
Method= MI:0004
PMID= 17545619

MAD2L1BP: 
Method= MI:0018;;MI:0018;;MI:0018;;MI:0398;;MI:0492
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

CDKN1A: 
Method= MI:0004;;MI:0006;;MI:0006;;MI:0493
PMID= 11896572;;16616141;;16616141;;17139261

PIWIL1: 
Method= MI:0004
PMID= 20308539

MED1: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0096;;MI:0004;;MI:0493;;MI:0006;;MI:0004;;MI:0006;;MI:0006
PMID= 15848166;;15848166;;15848166;;9444950;;9444950;;11118038;;15848166;;11118038;;15848166;;15848166

RPL23: 
Method= MI:0004;;MI:0004
PMID= 15308643;;15308643

EIF2S2: 
Method= MI:0492;;MI:0018;;MI:0018;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

PRMT1: 
Method= MI:0096;;MI:0492
PMID= 15186775;;15186775

PIN1: 
Method= MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0493;;MI:0096;;MI:0096;;MI:0096;;MI:0096
PMID= 12397362;;12397362;;12397362;;12397362;;12397362;;12397362;;12397361;;12397361;;12397362;;12397361;;12397361;;12388558;;12388558

SMARCA4: 
Method= MI:0004;;MI:0096;;MI:0493;;MI:0096;;MI:0096;;MI:0018;;MI:0006
PMID= 17666433;;11950834;;11950834;;11950834;;11950834;;18303029;;18303029

SNRPN: 
Method= MI:0492;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070

NEDD8: 
Method= MI:0004;;MI:0004;;MI:0493;;MI:0004;;MI:0004
PMID= 16620772;;17098746;;16620772;;17546054;;17369817

TEP1: 
Method= MI:0096;;MI:0493
PMID= 10597287;;10597287

SAT1: 
Method= MI:0018;;MI:0398;;MI:0018;;MI:0492;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

DNMT1: 
Method= MI:0004
PMID= 17991895

HABP4: 
Method= MI:0018;;MI:0018;;MI:0018;;MI:0018
PMID= 16455055;;16455055;;16455055;;16455055

PSME3: 
Method= MI:0004;;MI:0004;;MI:0492;;MI:0006;;MI:0004;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0492;;MI:0006
PMID= 18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296

MAP1B: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 18656471;;18656471;;18656471;;18656471;;18656471;;18656471;;18656471;;18656471;;18656471;;18656471;;18656471;;18656471

TOP2A: 
Method= MI:0004;;MI:0493;;MI:0004
PMID= 10666337;;10666337;;10666337

RPA1: 
Method= MI:0004;;MI:0493;;MI:0018;;MI:0096;;MI:0096;;MI:0411
PMID= 11751427;;11751427;;8663296;;15489903;;15489903;;15735006

GPS2: 
Method= MI:0493;;MI:0004;;MI:0004
PMID= 11486030;;11486030;;11486030

TOE1: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 19508870;;19508870;;19508870;;19508870;;19508870;;19508870

TPT1: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 21081126;;21081126;;21081126;;21081126;;21081126;;21081126;;21081126;;21081126;;21081126;;21081126

BTBD2: 
Method= MI:0018;;MI:0398;;MI:0018;;MI:0492;;MI:0018;;MI:0398
PMID= 16169070;;16169070;;16169070;;16169070;;16169070;;16169070

PRAM1: 
Method= MI:0004
PMID= 14976551

MKRN1: 
Method= MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096
PMID= 10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164;;10.1038/emboj.2009.164

DUSP26: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 20562916;;20562916;;20562916;;20562916;;20562916;;20562916;;20562916;;20562916;;20562916

MEN1: 
Method= MI:0004
PMID= 15960975

NUMB: 
Method= MI:0004;;MI:0004
PMID= 18172499;;18172499

CDK7: 
Method= MI:0415;;MI:0047;;MI:0493
PMID= 9372954;;9840937;;9840937

VHL: 
Method= MI:0004;;MI:0004;;MI:0004
PMID= 16678111;;16678111;;16678111

BHLHE40: 
Method= MI:0428;;MI:0428;;MI:0428;;MI:0428;;MI:0428;;MI:0428;;MI:0428;;MI:0428;;MI:0428;;MI:0428
PMID= 17347673;;17347673;;17347673;;17347673;;17347673;;17347673;;17347673;;17347673;;17347673;;17347673

CCNH: 
Method= MI:0047;;MI:0047;;MI:0493
PMID= 9840937;;9840937;;9840937

CABLES1: 
Method= MI:0492;;MI:0004;;MI:0019
PMID= 14637168;;14637168;;11706030

TEC: 
Method= MI:0492
PMID= 15355990

MDM2: 
Method= MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0492;;MI:0493;;MI:0493;;MI:0006;;MI:0411;;MI:0006;;MI:0006;;MI:0493;;MI:0493;;MI:0493;;MI:0493;;MI:0493;;MI:0004;;MI:0004;;MI:0004;;MI:0415;;MI:0096;;MI:0415;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0006;;MI:0004;;MI:0096;;MI:0411;;MI:0096;;MI:0018;;MI:0428;;MI:0096;;MI:0006;;MI:0006;;MI:0096;;MI:0096;;MI:0004;;MI:0428;;MI:0018;;MI:0401;;MI:0006;;MI:0006;;MI:0096;;MI:0096;;MI:0096;;MI:0006;;MI:0065;;MI:0415;;MI:0416;;MI:0004;;MI:0006;;MI:0096;;MI:0096;;MI:0006;;MI:0004;;MI:0004;;MI:0007;;MI:0007;;MI:0107;;MI:0007;;MI:0007;;MI:0006;;MI:0004;;MI:0415;;MI:0007;;MI:0428;;MI:0071;;MI:0006;;MI:0096;;MI:0018;;MI:0004;;MI:0004;;MI:0415;;MI:0004;;MI:0096;;MI:0096;;MI:0004;;MI:0004;;MI:0007;;MI:0114;;MI:0096;;MI:0004;;MI:0006;;MI:0004;;MI:0114;;MI:0107;;MI:0004;;MI:0071;;MI:0007;;MI:0096;;MI:0096;;MI:0004;;MI:0004;;MI:0096;;MI:0007;;MI:0428;;MI:0428;;MI:0007;;MI:0007;;MI:0428;;MI:0071;;MI:0004;;MI:0090;;MI:0415;;MI:0071;;MI:0004;;MI:0004;;MI:0004;;MI:0007;;MI:0004;;MI:0096;;MI:0007;;MI:0411;;MI:0004;;MI:0007;;MI:0007;;MI:0004;;MI:0096;;MI:0004;;MI:0004;;MI:0004;;MI:0096;;MI:0096;;MI:0004;;MI:0004;;MI:0096;;MI:0004;;MI:0096;;MI:0004;;MI:0428;;MI:0004;;MI:0004;;MI:0018;;MI:0018;;MI:0493;;MI:0415;;MI:0004;;MI:0004;;MI:0018;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0006;;MI:0006;;MI:0004;;MI:0114;;MI:0004;;MI:0004;;MI:0004;;MI:0415;;MI:0415;;MI:0096;;MI:0493;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0492;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 19098711;;19098711;;19098711;;19098711;;18632619;;17139261;;18566590;;15144954;;17875722;;12915590;;12915590;;10078201;;11562347;;18382127;;18566590;;17139261;;17470788;;11709713;;12620407;;14671306;;7686617;;18485870;;21454483;;11925449;;12612087;;11925449;;15308643;;15848166;;15542844;;16212962;;17875722;;16212962;;19166840;;12915590;;12915590;;15848166;;15848166;;12915590;;16579792;;16964247;;12915590;;11178989;;7926727;;18309296;;17268548;;16212962;;11384992;;16212962;;18309296;;19255450;;18485870;;20708156;;14612427;;15848166;;17525743;;14702041;;12915590;;12426395;;12426395;;19098711;;19098711;;14704432;;17139261;;17139261;;18309296;;15122315;;18665269;;17159902;;17347673;;20591429;;17268548;;11562347;;19166840;;15308643;;16107876;;10722742;;17098746;;14596917;;10196247;;17936559;;11431470;;17159902;;15154850;;15295102;;14612427;;18309296;;19223463;;15154850;;14704432;;16547496;;20591429;;17139261;;18332869;;18332869;;18172499;;18172499;;16866370;;17139261;;12915590;;12915590;;19098711;;19098711;;17347673;;20591429;;12167711;;15908921;;16857591;;20591429;;15064742;;17908790;;17908790;;19098711;;19085961;;9809062;;19098711;;17875722;;10892746;;19098711;;19098711;;17139261;;19166840;;17139261;;12208736;;19071110;;10766163;;9271120;;17369817;;16624812;;10196247;;15210108;;19303885;;12944468;;11744695;;16023600;;16023600;;9529249;;9529249;;16432196;;18485870;;21454483;;18309296;;10608892;;21454483;;19098711;;18172499;;17591690;;18223694;;19411066;;19411066;;15933712;;8875929;;17380154;;17363365;;11713288;;18485870;;18485870;;19188367;;7935455;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;18309296;;17310983;;17310983;;18952844;;18952844

MPHOSPH6: 
Method= MI:0018;;MI:0492;;MI:0398;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

TAF5L: 
Method= MI:0004
PMID= 18250150

NMT1: 
Method= MI:0006;;MI:0006;;MI:0493
PMID= 16530191;;16530191;;16530191

KAT7: 
Method= MI:0004;;MI:0004;;MI:0004
PMID= 17954561;;17954561;;17954561

WDR33: 
Method= MI:0018;;MI:0492;;MI:0398
PMID= 16169070;;16169070;;16169070

CDK9: 
Method= MI:0492
PMID= 16552184

TXN: 
Method= MI:0096
PMID= 19681600

KLF4: 
Method= MI:0493
PMID= 10749849

DAB2IP: 
Method= MI:0004
PMID= 20308539

APTX: 
Method= MI:0096;;MI:0096;;MI:0004;;MI:0004
PMID= 15044383;;15044383;;15044383;;15044383

RNF38: 
Method= MI:0004
PMID= 20308539

TFAP2A: 
Method= MI:0428;;MI:0428;;MI:0428;;MI:0493;;MI:0428
PMID= 12226108;;12226108;;12226108;;12226108;;12226108

MDC1: 
Method= MI:0004;;MI:0493
PMID= 14519663;;14519663

PRKRIR: 
Method= MI:0004
PMID= 12384512

FXYD6: 
Method= MI:0492;;MI:0398;;MI:0018;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

FBXO11: 
Method= MI:0096;;MI:0004;;MI:0493;;MI:0004;;MI:0004;;MI:0096;;MI:0096
PMID= 17098746;;17098746;;17098746;;17098746;;17098746;;17098746;;17098746

LRPPRC: 
Method= MI:0004
PMID= 20308539

ARL3: 
Method= MI:0398;;MI:0018;;MI:0018;;MI:0492;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

BARD1: 
Method= MI:0401;;MI:0006;;MI:0493;;MI:0401;;MI:0004
PMID= 14636569;;15782130;;15782130;;14636569;;15782130

HECW2: 
Method= MI:0004
PMID= 12890487

COX17: 
Method= MI:0018;;MI:0018;;MI:0018;;MI:0492;;MI:0398
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

COPS4: 
Method= MI:0492;;MI:0492
PMID= 11285227;;11285227

ANXA3: 
Method= MI:0492;;MI:0398;;MI:0018;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

TDG: 
Method= MI:0018
PMID= 10961991

BRCA2: 
Method= MI:0004;;MI:0401;;MI:0401;;MI:0401;;MI:0493;;MI:0019
PMID= 9811893;;14636569;;14636569;;14636569;;9811893;;9811893

NCOA2: 
Method= MI:0676
PMID= 20195357

PML: 
Method= MI:0006;;MI:0006;;MI:0096;;MI:0006;;MI:0004;;MI:0493;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0428;;MI:0428;;MI:0096;;MI:0428;;MI:0428
PMID= 12915590;;12915590;;12915590;;12915590;;11025664;;11704853;;11025664;;11080164;;14976551;;11080164;;12915590;;12915590;;12915590;;12915590;;12915590

NOL3: 
Method= MI:0807
PMID= 18087040

NCOR1: 
Method= MI:0004
PMID= 19011633

COPS3: 
Method= MI:0492;;MI:0492
PMID= 11285227;;11285227

CSNK1D: 
Method= MI:0493
PMID= 9349507

SAE1: 
Method= MI:0007;;MI:0007
PMID= 15327968;;15327968

RPL11: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0004
PMID= 14612427;;15308643;;14612427;;15308643

SERBP1: 
Method= MI:0018
PMID= 16455055

RFWD2: 
Method= MI:0007;;MI:0007;;MI:0492;;MI:0004;;MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0007
PMID= 15103385;;15103385;;15103385;;16931761;;15103385;;15103385;;15103385;;15103385;;15103385;;15103385

TAF1A: 
Method= MI:0096;;MI:0492
PMID= 10913176;;10913176

SMYD2: 
Method= MI:0492;;MI:0004;;MI:0415;;MI:0415
PMID= 17108971;;18065756;;17108971;;17108971

TP53BP2: 
Method= MI:0114;;MI:0492;;MI:0065;;MI:0018;;MI:0018;;MI:0018;;MI:0114;;MI:0018;;MI:0018;;MI:0114;;MI:0114;;MI:0018;;MI:0018
PMID= 8875926;;8016121;;18275817;;8668206;;8668206;;8668206;;8875926;;8016121;;8016121;;8875926;;8875926;;8016121;;8016121

S100A8: 
Method= MI:0018;;MI:0018;;MI:0492;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

ACTA1: 
Method= MI:0492
PMID= 11821948

PARP1: 
Method= MI:0004;;MI:0004;;MI:0047;;MI:0006;;MI:0096;;MI:0096;;MI:0493;;MI:0096;;MI:0096
PMID= 9312059;;15044383;;9565608;;14627987;;12898523;;12898523;;9565608;;12898523;;12898523

RPS27A: 
Method= MI:0006;;MI:0006
PMID= 18695251;;18695251

ANK2: 
Method= MI:0676
PMID= 20195357

CCNA2: 
Method= MI:0493;;MI:0415
PMID= 10884347;;10884347

SETD7: 
Method= MI:0415;;MI:0415;;MI:0415;;MI:0493;;MI:0415;;MI:0516;;MI:0415;;MI:0415;;MI:0415;;MI:0415;;MI:0515;;MI:0415;;MI:0415
PMID= 15525938;;15525938;;15525938;;15525938;;15525938;;16415881;;15525938;;15525938;;15525938;;15525938;;16415881;;15525938;;17108971

HDAC8: 
Method= MI:0114;;MI:0114
PMID= 17721440;;17721440

TAF1: 
Method= MI:0004
PMID= 10359315

CDKN2A: 
Method= MI:0018;;MI:0004;;MI:0018;;MI:0018;;MI:0004
PMID= 12446718;;14612427;;9529249;;9529249;;14612427

INPP5E: 
Method= MI:0004
PMID= 20308539

SERPINH1: 
Method= MI:0004
PMID= 17977830

ATM: 
Method= MI:0424;;MI:0045;;MI:0415;;MI:0045;;MI:0492;;MI:0096;;MI:0415;;MI:0096;;MI:0096;;MI:0686;;MI:0415;;MI:0096
PMID= 19015526;;10864201;;17409407;;10864201;;9765199;;9843217;;15064416;;9843217;;15632067;;10608806;;15064416;;15159397

MTA2: 
Method= MI:0004;;MI:0493;;MI:0096;;MI:0096;;MI:0096
PMID= 12920132;;11099047;;11099047;;11099047;;11099047

CHEK1: 
Method= MI:0004;;MI:0004;;MI:0019;;MI:0492;;MI:0004;;MI:0096;;MI:0019
PMID= 11896572;;15364958;;16511572;;11896572;;11896572;;12756247;;16511572

CABLES2: 
Method= MI:0004;;MI:0492
PMID= 14637168;;14637168

PPP4C: 
Method= MI:0018
PMID= 9837938

CCT5: 
Method= MI:0398;;MI:0018;;MI:0018;;MI:0492;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

UBC: 
Method= MI:0007;;MI:0007;;MI:0007;;MI:0107;;MI:0096;;MI:0006;;MI:0096;;MI:0007;;MI:0006;;MI:0006;;MI:0096;;MI:0007;;MI:0006;;MI:0006;;MI:0007;;MI:0096;;MI:0007;;MI:0006;;MI:0006;;MI:0107;;MI:0006;;MI:0006;;MI:0096;;MI:0007;;MI:0006;;MI:0096;;MI:0096;;MI:0096;;MI:0006;;MI:0006
PMID= 19098711;;17568776;;17568776;;19798103;;17290220;;18566590;;10.1038/emboj.2009.164;;19098711;;18309296;;17268548;;17170702;;17159902;;18309296;;19619542;;17139261;;17170702;;17159902;;19619542;;19619542;;19798103;;17268548;;19619542;;10.1038/emboj.2009.164;;17139261;;18566590;;17290220;;18388957;;18388957;;18566590;;18566590

THRB: 
Method= MI:0004;;MI:0045;;MI:0493
PMID= 11258898;;8633054;;11258898

TADA1: 
Method= MI:0004
PMID= 18250150

JMY: 
Method= MI:0006
PMID= 10518217

NMT2: 
Method= MI:0006;;MI:0493;;MI:0006
PMID= 16530191;;16530191;;16530191

ING1: 
Method= MI:0004;;MI:0004;;MI:0492;;MI:0004
PMID= 19085961;;9440695;;12208736;;12208736

PRKCA: 
Method= MI:0493
PMID= 9935181

UCHL1: 
Method= MI:0004
PMID= 18666234

ZCCHC10: 
Method= MI:0492;;MI:0018;;MI:0018;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

RNF20: 
Method= MI:0096;;MI:0096;;MI:0402
PMID= 16337599;;16337599;;19410543

BACH1: 
Method= MI:0004;;MI:0004;;MI:0004
PMID= 19011633;;19011633;;19011633

PPP2R2B: 
Method= MI:0493
PMID= 17245430

BRE: 
Method= MI:0401;;MI:0401;;MI:0401
PMID= 14636569;;14636569;;14636569

CDC25C: 
Method= MI:0493
PMID= 10853038

DYNC1I1: 
Method= MI:0006;;MI:0006
PMID= 16616141;;16616141

IGF2BP1: 
Method= MI:0004
PMID= 20308539

PADI4: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004
PMID= 18505818;;20190809;;18505818;;18505818;;18505818;;18505818

S100B: 
Method= MI:0071;;MI:0004;;MI:0071;;MI:0071;;MI:0004;;MI:0071;;MI:0492
PMID= 20591429;;15178678;;20591429;;20591429;;15178678;;20591429;;11527429

S100A1: 
Method= MI:0071;;MI:0071;;MI:0071;;MI:0071
PMID= 20591429;;20591429;;20591429;;20591429

THAP8: 
Method= MI:0492;;MI:0018;;MI:0398;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

ZNF385A: 
Method= MI:0006
PMID= 17719541

STX5: 
Method= MI:0492;;MI:0018;;MI:0018;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

SYVN1: 
Method= MI:0096;;MI:0493;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096;;MI:0096
PMID= 17170702;;17170702;;17170702;;17170702;;17170702;;17170702;;17170702;;17170702;;17170702;;17170702;;17170702

ATF3: 
Method= MI:0004;;MI:0004;;MI:0492;;MI:0398;;MI:0004;;MI:0004;;MI:0018;;MI:0004
PMID= 11792711;;11792711;;11792711;;16169070;;15933712;;15933712;;16169070;;15933712

MSX1: 
Method= MI:0493
PMID= 15705871

ERCC3: 
Method= MI:0492;;MI:0096;;MI:0096
PMID= 7663514;;7663514;;7663514

HIPK1: 
Method= MI:0018;;MI:0006;;MI:0018;;MI:0006;;MI:0493;;MI:0018
PMID= 12702766;;12702766;;12702766;;12702766;;12702766;;12702766

MNDA: 
Method= MI:0492
PMID= 16458891

IFI16: 
Method= MI:0004;;MI:0493
PMID= 11146555;;11146555

RYBP: 
Method= MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0004
PMID= 19098711;;19098711;;19098711;;19098711;;19098711

RCHY1: 
Method= MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0096;;MI:0007;;MI:0007;;MI:0004;;MI:0007;;MI:0004;;MI:0808;;MI:0096;;MI:0007;;MI:0007;;MI:0007;;MI:0493
PMID= 17568776;;17568776;;17568776;;17568776;;19043414;;17568776;;17568776;;12654245;;17568776;;12654245;;19043414;;19043414;;17568776;;17568776;;17568776;;12654245

ZNF148: 
Method= MI:0493;;MI:0004;;MI:0004
PMID= 11416144;;11416144;;11416144

GNL3: 
Method= MI:0096;;MI:0096;;MI:0096;;MI:0493;;MI:0006
PMID= 12464630;;12464630;;12464630;;12464630;;12464630

SHISA5: 
Method= MI:0492
PMID= 12135983

HMGB2: 
Method= MI:0492
PMID= 11748232

PTTG1: 
Method= MI:0493;;MI:0004;;MI:0004;;MI:0004
PMID= 12355087;;12355087;;12355087;;12355087

CDK5: 
Method= MI:0493;;MI:0004;;MI:0004;;MI:0004
PMID= 11483158;;17591690;;17591690;;17591690

YWHAZ: 
Method= MI:0424;;MI:0493;;MI:0004;;MI:0004;;MI:0424
PMID= 16376338;;9620776;;9620776;;9620776;;16376338

TP53INP1: 
Method= MI:0096;;MI:0096;;MI:0492;;MI:0096;;MI:0096
PMID= 12851404;;12851404;;11511362;;12851404;;11511362

ZHX1: 
Method= MI:0018
PMID= 15383276

WRN: 
Method= MI:0096;;MI:0416;;MI:0004;;MI:0416;;MI:0411;;MI:0411;;MI:0416;;MI:0493;;MI:0004
PMID= 11427532;;11427532;;12080066;;11427532;;15735006;;15735006;;11427532;;11427532;;12080066

ANKRD2: 
Method= MI:0493;;MI:0004;;MI:0004
PMID= 15136035;;15136035;;15136035

AGBL2: 
Method= MI:0004
PMID= 20308539

COPS2: 
Method= MI:0492;;MI:0492
PMID= 11285227;;11285227

TAF10: 
Method= MI:0004
PMID= 18250150

PLK1: 
Method= MI:0424;;MI:0006;;MI:0006;;MI:0006;;MI:0424;;MI:0006;;MI:0493;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 19833129;;16753148;;16753148;;16753148;;19833129;;16753148;;16753148;;16753148;;16753148;;16753148;;16753148

STAT6: 
Method= MI:0018
PMID= 20121258

SMAD3: 
Method= MI:0493
PMID= 12732139

PHB: 
Method= MI:0663;;MI:0663;;MI:0663;;MI:0428;;MI:0493;;MI:0663;;MI:0006;;MI:0006;;MI:0428;;MI:0428
PMID= 16319068;;16319068;;16319068;;14500729;;14500729;;16319068;;20134482;;20134482;;14500729;;14500729

EEF2: 
Method= MI:0004;;MI:0493
PMID= 12891704;;12891704

TK1: 
Method= MI:0492;;MI:0398;;MI:0018;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

E4F1: 
Method= MI:0018;;MI:0018;;MI:0493;;MI:0018;;MI:0018
PMID= 10644996;;10644996;;10644996;;10644996;;12446718

PBK: 
Method= MI:0006;;MI:0018;;MI:0018;;MI:0006;;MI:0018;;MI:0006;;MI:0018;;MI:0006
PMID= 20622899;;17482142;;17482142;;20622899;;17482142;;20622899;;17482142;;20622899

COPS6: 
Method= MI:0492;;MI:0492
PMID= 11285227;;11285227

RAB4A: 
Method= MI:0018;;MI:0018;;MI:0018;;MI:0398;;MI:0492
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

ING5: 
Method= MI:0493;;MI:0004;;MI:0004;;MI:0004;;MI:0004
PMID= 12750254;;12750254;;17954561;;12750254;;17954561

BMP1: 
Method= MI:0663
PMID= 18624398

TRAPPC11: 
Method= MI:0004
PMID= 20308539

ING2: 
Method= MI:0493;;MI:0006;;MI:0004;;MI:0006
PMID= 16782091;;16782091;;16024799;;16782091

GSTM4: 
Method= MI:0492;;MI:0018;;MI:0018;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

USP39: 
Method= MI:0004;;MI:0007
PMID= 19615732;;19615732

AR: 
Method= MI:0018;;MI:0018;;MI:0018
PMID= 19481544;;19481544;;11504717

SIN3A: 
Method= MI:0006;;MI:0004;;MI:0401;;MI:0493;;MI:0004;;MI:0004
PMID= 11359905;;10521394;;10823891;;10823891;;10521394;;10521394

PTK2: 
Method= MI:0493;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0401;;MI:0006;;MI:0401;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 15855171;;15855171;;15855171;;15855171;;15855171;;15855171;;15855171;;19857493;;18206965;;15855171;;18206965;;15855171;;15855171;;15855171;;19857493;;15855171

STRA13: 
Method= MI:0493
PMID= 17347673

GPS1: 
Method= MI:0492;;MI:0492
PMID= 11285227;;11285227

CHD3: 
Method= MI:0018;;MI:0018
PMID= 10961991;;10961991

YWHAG: 
Method= MI:0053;;MI:0019;;MI:0019;;MI:0019;;MI:0053;;MI:0053;;MI:0019;;MI:0019;;MI:0019;;MI:0053;;MI:0053;;MI:0493;;MI:0053
PMID= 18812399;;19933256;;19933256;;19933256;;18812399;;18812399;;19933256;;19933256;;19933256;;18812399;;18812399;;15324660;;18812399

CDK1: 
Method= MI:0493;;MI:0415;;MI:0004;;MI:0045
PMID= 11327730;;10884347;;11327730;;9467949

UBB: 
Method= MI:0006
PMID= 17936559

SERPINB9: 
Method= MI:0018;;MI:0398;;MI:0018;;MI:0492;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

HSPA4: 
Method= MI:0004
PMID= 18223694

PPM1D: 
Method= MI:0493
PMID= 17936559

TRIAP1: 
Method= MI:0493
PMID= 15735003

TADA3: 
Method= MI:0018;;MI:0004;;MI:0004;;MI:0493
PMID= 11707411;;17452980;;18250150;;11707411

BCL2L1: 
Method= MI:0493;;MI:0096;;MI:0096;;MI:0493
PMID= 16151013;;16151013;;16151013;;12667443

SPSB1: 
Method= MI:0004
PMID= 20308539

HDAC3: 
Method= MI:0493
PMID= 10777477

BCL2: 
Method= MI:0416;;MI:0416;;MI:0416;;MI:0416;;MI:0416;;MI:0416;;MI:0493;;MI:0045
PMID= 10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;12667443;;9194558

RRM2: 
Method= MI:0019;;MI:0004;;MI:0493
PMID= 12615712;;12615712;;12615712

PTEN: 
Method= MI:0004;;MI:0004;;MI:0493
PMID= 12620407;;12620407;;12620407

CEBPB: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 16227626;;16227626;;16227626;;16227626

TP53RK: 
Method= MI:0492;;MI:0018
PMID= 11546806;;12659830

ZNF24: 
Method= MI:0018;;MI:0018;;MI:0018;;MI:0492;;MI:0398
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

BANP: 
Method= MI:0006;;MI:0006;;MI:0493;;MI:0006;;MI:0096;;MI:0096;;MI:0006;;MI:0006;;MI:0006;;MI:0096
PMID= 10.1038/emboj.2009.395;;10.1038/emboj.2009.395;;15701641;;10.1038/emboj.2009.395;;19303885;;19303885;;10.1038/emboj.2009.395;;10.1038/emboj.2009.395;;10.1038/emboj.2009.395;;19303885

PPP1CA: 
Method= MI:0018;;MI:0018;;MI:0018
PMID= 15231748;;15231748;;15231748

EFEMP2: 
Method= MI:0493
PMID= 10380882

SP3: 
Method= MI:0493;;MI:0004
PMID= 15790310;;12665570

KAT5: 
Method= MI:0004;;MI:0415;;MI:0415;;MI:0493;;MI:0004;;MI:0004;;MI:0004
PMID= 16601686;;18485870;;18485870;;16601686;;18280244;;16601686;;15310756

SMARCC1: 
Method= MI:0018;;MI:0096;;MI:0006
PMID= 18303029;;11950834;;18303029

CCDC106: 
Method= MI:0416;;MI:0018;;MI:0416;;MI:0416;;MI:0492;;MI:0416;;MI:0398
PMID= 20159018;;16169070;;20159018;;20159018;;16169070;;20159018;;16169070

PLK3: 
Method= MI:0415;;MI:0415;;MI:0415;;MI:0415;;MI:0492
PMID= 12242661;;12242661;;11551930;;11551930;;11551930

ATR: 
Method= MI:0424;;MI:0492;;MI:0686;;MI:0096
PMID= 16293623;;9765199;;10608806;;15159397

SMAD2: 
Method= MI:0493;;MI:0006;;MI:0006;;MI:0006
PMID= 12732139;;19345189;;19345189;;19345189

SFN: 
Method= MI:0065;;MI:0004;;MI:0065;;MI:0004;;MI:0065;;MI:0004;;MI:0004;;MI:0065
PMID= 20206173;;11896572;;20206173;;14517281;;20206173;;14517281;;17546054;;20206173

DLEU1: 
Method= MI:0018;;MI:0492;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070

MAGEB18: 
Method= MI:0096;;MI:0018;;MI:0018;;MI:0018;;MI:0018;;MI:0096;;MI:0096;;MI:0398
PMID= 16713569;;16189514;;16189514;;16189514;;16189514;;16713569;;16713569;;16189514

ARIH2: 
Method= MI:0018;;MI:0492;;MI:0398;;MI:0018;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

UBE2N: 
Method= MI:0096;;MI:0096;;MI:0096
PMID= 17000756;;17000756;;17000756

ZBTB7A: 
Method= MI:0004;;MI:0004
PMID= 19244234;;19244234

RAD23A: 
Method= MI:0004
PMID= 15064742

PRKRA: 
Method= MI:0096;;MI:0096;;MI:0493
PMID= 9010216;;9010216;;9010216

PPA1: 
Method= MI:0492;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070

NQO1: 
Method= MI:0493;;MI:0019
PMID= 12529318;;12529318

NPM1: 
Method= MI:0019;;MI:0019;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0493;;MI:0107;;MI:0107;;MI:0107;;MI:0107;;MI:0107;;MI:0004;;MI:0107
PMID= 12080348;;12080348;;15144954;;15144954;;15144954;;15144954;;12080348;;16376884;;16376884;;16376884;;16376884;;16376884;;16740634;;16376884

ZBTB2: 
Method= MI:0004;;MI:0004
PMID= 19380588;;19380588

SETD2: 
Method= MI:0004;;MI:0004
PMID= 18585004;;18585004

KPNA2: 
Method= MI:0493
PMID= 10930427

NDN: 
Method= MI:0492;;MI:0018;;MI:0018
PMID= 10347180;;10347180;;10347180

MTA1: 
Method= MI:0004;;MI:0492;;MI:0004;;MI:0004;;MI:0004;;MI:0428
PMID= 12920132;;12920132;;17914590;;17914590;;17914590;;20071335

MAGEA2B: 
Method= MI:0004;;MI:0004
PMID= 16847267;;16847267

SSTR3: 
Method= MI:0493
PMID= 8961277

CHEK2: 
Method= MI:0493;;MI:0004;;MI:0424;;MI:0096;;MI:0096;;MI:0424
PMID= 17157788;;12810724;;18833288;;15862297;;15862297;;18833288

WT1: 
Method= MI:0493;;MI:0004
PMID= 8389468;;8389468

BRF1: 
Method= MI:0493;;MI:0004
PMID= 8943363;;8943363

MAPK11: 
Method= MI:0424;;MI:0424;;MI:0424;;MI:0424
PMID= 17254968;;17254968;;17254968;;17254968

BRCC3: 
Method= MI:0401;;MI:0401;;MI:0401
PMID= 14636569;;14636569;;14636569

SP1: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0004;;MI:0493;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0006;;MI:0004;;MI:0004
PMID= 15710382;;15710382;;15710382;;15710382;;15710382;;8463313;;9492043;;15674334;;15674334;;18765668;;12665570;;12665570;;12665570;;15710382;;12665570;;16740634

PAGR1: 
Method= MI:0007;;MI:0007
PMID= 19039327;;19039327

WWOX: 
Method= MI:0006;;MI:0018;;MI:0006;;MI:0006;;MI:0006;;MI:0493;;MI:0006;;MI:0018;;MI:0006;;MI:0006;;MI:0006;;MI:0493
PMID= 15580310;;11058590;;15580310;;15580310;;15580310;;11058590;;15580310;;11058590;;15580310;;15580310;;15580310;;15580310

PPP1CC: 
Method= MI:0006;;MI:0493;;MI:0006
PMID= 17274640;;17274640;;17274640

BCR: 
Method= MI:0398;;MI:0018;;MI:0492
PMID= 16169070;;16169070;;16169070

NAP1L1: 
Method= MI:0492;;MI:0018;;MI:0018;;MI:0018;;MI:0018
PMID= 14966293;;14966293;;14966293;;14966293;;14966293

TAF9B: 
Method= MI:0492
PMID= 7761466

USP7: 
Method= MI:0045;;MI:0045;;MI:0045;;MI:0114;;MI:0007;;MI:0004;;MI:0114;;MI:0114;;MI:0114;;MI:0114;;MI:0004;;MI:0686;;MI:0004;;MI:0004;;MI:0006;;MI:0045;;MI:0045;;MI:0493;;MI:0096;;MI:0006;;MI:0045;;MI:0045;;MI:0004;;MI:0096;;MI:0045;;MI:0096;;MI:0686;;MI:0114
PMID= 11923872;;11923872;;11923872;;16474402;;21170034;;11923872;;16474402;;16474402;;16474402;;16474402;;11923872;;16402859;;11923872;;11923872;;17268548;;11923872;;11923872;;11923872;;16474402;;17268548;;11923872;;11923872;;17380154;;17525743;;11923872;;17525743;;16402859;;16474402

H2AFX: 
Method= MI:0004;;MI:0004
PMID= 16322227;;16322227

HMGB1: 
Method= MI:0047;;MI:0096;;MI:0045;;MI:0004;;MI:0492;;MI:0004;;MI:0004;;MI:0004
PMID= 9472015;;11748221;;9472015;;11106654;;9472015;;11106654;;11106654;;11106654

S100A4: 
Method= MI:0096;;MI:0492;;MI:0071;;MI:0047;;MI:0047;;MI:0071;;MI:0071;;MI:0071
PMID= 11527429;;11527429;;20591429;;19740107;;19740107;;20591429;;20591429;;20591429

SUPT3H: 
Method= MI:0004
PMID= 18250150

WDR5: 
Method= MI:0004
PMID= 15960975

TRRAP: 
Method= MI:0004;;MI:0096;;MI:0096;;MI:0096
PMID= 18250150;;12138177;;12138177;;12138177

XRCC6: 
Method= MI:0004;;MI:0493;;MI:0006;;MI:0006;;MI:0004
PMID= 15782130;;15782130;;15782130;;15782130;;15782130

HDAC2: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0493
PMID= 20190809;;17827154;;14976551;;10777477

DAPK1: 
Method= MI:0004;;MI:0004
PMID= 17339337;;17339337

S100A2: 
Method= MI:0071;;MI:0071;;MI:0071;;MI:0071;;MI:0492
PMID= 20591429;;20591429;;20591429;;20591429;;15941720

ZNF420: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0004
PMID= 19377469;;19377469;;19377469;;19377469

BLM: 
Method= MI:0004;;MI:0004;;MI:0004;;MI:0493;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0004;;MI:0492;;MI:0493
PMID= 12080066;;15364958;;12080066;;11781842;;11399766;;11399766;;11399766;;11781842;;15364958;;11399766;;11781842;;15364958;;15364958;;15064730

HTT: 
Method= MI:0096;;MI:0096;;MI:0401;;MI:0401;;MI:0401;;MI:0493;;MI:0401
PMID= 10823891;;10823891;;10823891;;10823891;;10823891;;10823891;;10823891

TOPORS: 
Method= MI:0415;;MI:0428;;MI:0493;;MI:0018;;MI:0096;;MI:0428
PMID= 15247280;;17290218;;10415337;;11842245;;17803295;;17290218

ADH5: 
Method= MI:0004
PMID= 20308539

S100A6: 
Method= MI:0071;;MI:0071
PMID= 20591429;;20591429

PRIM1: 
Method= MI:0493
PMID= 11917009

TFDP1: 
Method= MI:0492;;MI:0004;;MI:0004
PMID= 8816502;;8816502;;8816502

MAFK: 
Method= MI:0004
PMID= 19011633

COPS8: 
Method= MI:0492;;MI:0492
PMID= 11285227;;11285227

MDM4: 
Method= MI:0004;;MI:0018;;MI:0077;;MI:0415;;MI:0077;;MI:0416;;MI:0096;;MI:0096;;MI:0411;;MI:0077;;MI:0493;;MI:0411;;MI:0415;;MI:0416;;MI:0004;;MI:0077;;MI:0018;;MI:0019;;MI:0416;;MI:0416;;MI:0416;;MI:0416;;MI:0416;;MI:0416;;MI:0411
PMID= 16227609;;15604276;;20515689;;18485870;;20515689;;10.1038/emboj.2009.154;;9226370;;9226370;;17875722;;20515689;;8895579;;17875722;;12393902;;10.1038/emboj.2009.154;;16024788;;20515689;;15604276;;11223036;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;10.1038/emboj.2009.154;;17875722

MTOR: 
Method= MI:0006;;MI:0006
PMID= 19619545;;19619545

PNP: 
Method= MI:0018;;MI:0492;;MI:0018;;MI:0398;;MI:0018
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

TOP1: 
Method= MI:0493;;MI:0004;;MI:0018
PMID= 10468612;;10468612;;11805286

DAXX: 
Method= MI:0007;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0007;;MI:0007;;MI:0018;;MI:0007;;MI:0416;;MI:0493;;MI:0007;;MI:0007;;MI:0007;;MI:0007;;MI:0018
PMID= 15364927;;16845383;;16845383;;16845383;;16845383;;16845383;;16845383;;16845383;;15364927;;15364927;;14557665;;15364927;;14557665;;12954772;;15364927;;15364927;;15364927;;15364927;;14557665

HSPA1B: 
Method= MI:0493;;MI:0493
PMID= 7811761;;17184779

HSPA1L: 
Method= MI:0006;;MI:0006
PMID= 17184779;;17184779

CSNK2B: 
Method= MI:0493
PMID= 10214938

PCDHA4: 
Method= MI:0018;;MI:0492;;MI:0018;;MI:0018;;MI:0398
PMID= 16169070;;16169070;;16169070;;16169070;;16169070

MT1A: 
Method= MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006;;MI:0006
PMID= 16442532;;16442532;;16442532;;16442532;;16442532;;16442532

TMSB4X: 
Method= MI:0398
PMID= 16169070

CHUK: 
Method= MI:0493
PMID= 11805286

SNURF: 
Method= MI:0018;;MI:0018
PMID= 16169070;;16169070

PPP2R2A: 
Method= MI:0006;;MI:0006
PMID= 17245430;;17245430

ERCC6: 
Method= MI:0493;;MI:0096;;MI:0004;;MI:0004
PMID= 10882116;;7663514;;10882116;;10882116

DHFR: 
Method= MI:0492;;MI:0004
PMID= 18451149;;18451149

MIF: 
Method= MI:0493
PMID= 18815136

PRKDC: 
Method= MI:0096;;MI:0018;;MI:0492;;MI:0686
PMID= 12756247;;9679063;;10470151;;10608806
</pre></dd></dl>

### Subsetting

Here we query a database for all connections between a set of entities.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/knowledge_base'
require 'rbbt/util/tmpfile'
require 'rbbt/sources/organism'

require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'genomics_kb'

gene = "TP53"
found = Genomics.knowledge_base.identify :pina, gene
p53_interactors = Genomics.knowledge_base.children(:pina, found).target_entity

found = Genomics.knowledge_base.identify :kegg, gene
p53_pathways = Genomics.knowledge_base.children(:kegg, found).target_entity

entities = {"Gene" => p53_interactors, "KeggPathway" => p53_pathways}

puts "Interactors of #{gene} with common kegg pathways"
puts
Genomics.knowledge_base.subset(:kegg, entities).each do |match|
  puts match, [match.source_entity.name, match.target_entity.name, match.database, match.info.inspect] * ", "
end

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Interactors of TP53 with common kegg pathways

ENSG00000050748~hsa04010
MAPK9, MAPK signaling pathway, kegg, {}
ENSG00000058335~hsa04010
RASGRF1, MAPK signaling pathway, kegg, {}
ENSG00000070831~hsa04010
CDC42, MAPK signaling pathway, kegg, {}
ENSG00000089022~hsa04010
MAPKAPK5, MAPK signaling pathway, kegg, {}
ENSG00000100030~hsa04010
MAPK1, MAPK signaling pathway, kegg, {}
ENSG00000101109~hsa04010
STK4, MAPK signaling pathway, kegg, {}
ENSG00000102882~hsa04010
MAPK3, MAPK signaling pathway, kegg, {}
ENSG00000104365~hsa04010
IKBKB, MAPK signaling pathway, kegg, {}
ENSG00000106211~hsa04010
HSPB1, MAPK signaling pathway, kegg, {}
ENSG00000107643~hsa04010
MAPK8, MAPK signaling pathway, kegg, {}
ENSG00000109339~hsa04010
MAPK10, MAPK signaling pathway, kegg, {}
ENSG00000109971~hsa04010
HSPA8, MAPK signaling pathway, kegg, {}
ENSG00000123358~hsa04010
NR4A1, MAPK signaling pathway, kegg, {}
ENSG00000154229~hsa04010
PRKCA, MAPK signaling pathway, kegg, {}
ENSG00000185386~hsa04010
MAPK11, MAPK signaling pathway, kegg, {}
ENSG00000204209~hsa04010
DAXX, MAPK signaling pathway, kegg, {}
ENSG00000204388~hsa04010
HSPA1B, MAPK signaling pathway, kegg, {}
ENSG00000204390~hsa04010
HSPA1L, MAPK signaling pathway, kegg, {}
ENSG00000213341~hsa04010
CHUK, MAPK signaling pathway, kegg, {}
ENSG00000005339~hsa04110
CREBBP, Cell cycle, kegg, {}
ENSG00000079335~hsa04110
CDC14A, Cell cycle, kegg, {}
ENSG00000081377~hsa04110
CDC14B, Cell cycle, kegg, {}
ENSG00000082701~hsa04110
GSK3B, Cell cycle, kegg, {}
ENSG00000097007~hsa04110
ABL1, Cell cycle, kegg, {}
ENSG00000100393~hsa04110
EP300, Cell cycle, kegg, {}
ENSG00000101412~hsa04110
E2F1, Cell cycle, kegg, {}
ENSG00000108953~hsa04110
YWHAE, Cell cycle, kegg, {}
ENSG00000116478~hsa04110
HDAC1, Cell cycle, kegg, {}
ENSG00000123080~hsa04110
CDKN2C, Cell cycle, kegg, {}
ENSG00000123374~hsa04110
CDK2, Cell cycle, kegg, {}
ENSG00000124762~hsa04110
CDKN1A, Cell cycle, kegg, {}
ENSG00000134058~hsa04110
CDK7, Cell cycle, kegg, {}
ENSG00000134480~hsa04110
CCNH, Cell cycle, kegg, {}
ENSG00000135679~hsa04110
MDM2, Cell cycle, kegg, {}
ENSG00000145386~hsa04110
CCNA2, Cell cycle, kegg, {}
ENSG00000147889~hsa04110
CDKN2A, Cell cycle, kegg, {}
ENSG00000149311~hsa04110
ATM, Cell cycle, kegg, {}
ENSG00000149554~hsa04110
CHEK1, Cell cycle, kegg, {}
ENSG00000158402~hsa04110
CDC25C, Cell cycle, kegg, {}
ENSG00000164611~hsa04110
PTTG1, Cell cycle, kegg, {}
ENSG00000164924~hsa04110
YWHAZ, Cell cycle, kegg, {}
ENSG00000166851~hsa04110
PLK1, Cell cycle, kegg, {}
ENSG00000166949~hsa04110
SMAD3, Cell cycle, kegg, {}
ENSG00000170027~hsa04110
YWHAG, Cell cycle, kegg, {}
ENSG00000170312~hsa04110
CDK1, Cell cycle, kegg, {}
ENSG00000175054~hsa04110
ATR, Cell cycle, kegg, {}
ENSG00000175387~hsa04110
SMAD2, Cell cycle, kegg, {}
ENSG00000175793~hsa04110
SFN, Cell cycle, kegg, {}
ENSG00000183765~hsa04110
CHEK2, Cell cycle, kegg, {}
ENSG00000196591~hsa04110
HDAC2, Cell cycle, kegg, {}
ENSG00000198176~hsa04110
TFDP1, Cell cycle, kegg, {}
ENSG00000048392~hsa04115
RRM2B, p53 signaling pathway, kegg, {}
ENSG00000078900~hsa04115
TP73, p53 signaling pathway, kegg, {}
ENSG00000113328~hsa04115
CCNG1, p53 signaling pathway, kegg, {}
ENSG00000123374~hsa04115
CDK2, p53 signaling pathway, kegg, {}
ENSG00000124762~hsa04115
CDKN1A, p53 signaling pathway, kegg, {}
ENSG00000135679~hsa04115
MDM2, p53 signaling pathway, kegg, {}
ENSG00000143207~hsa04115
RFWD2, p53 signaling pathway, kegg, {}
ENSG00000147889~hsa04115
CDKN2A, p53 signaling pathway, kegg, {}
ENSG00000149311~hsa04115
ATM, p53 signaling pathway, kegg, {}
ENSG00000149554~hsa04115
CHEK1, p53 signaling pathway, kegg, {}
ENSG00000163743~hsa04115
RCHY1, p53 signaling pathway, kegg, {}
ENSG00000164054~hsa04115
SHISA5, p53 signaling pathway, kegg, {}
ENSG00000170312~hsa04115
CDK1, p53 signaling pathway, kegg, {}
ENSG00000170836~hsa04115
PPM1D, p53 signaling pathway, kegg, {}
ENSG00000171848~hsa04115
RRM2, p53 signaling pathway, kegg, {}
ENSG00000171862~hsa04115
PTEN, p53 signaling pathway, kegg, {}
ENSG00000175054~hsa04115
ATR, p53 signaling pathway, kegg, {}
ENSG00000175793~hsa04115
SFN, p53 signaling pathway, kegg, {}
ENSG00000183765~hsa04115
CHEK2, p53 signaling pathway, kegg, {}
ENSG00000198625~hsa04115
MDM4, p53 signaling pathway, kegg, {}
ENSG00000003402~hsa04210
CFLAR, Apoptosis, kegg, {}
ENSG00000014216~hsa04210
CAPN1, Apoptosis, kegg, {}
ENSG00000100906~hsa04210
NFKBIA, Apoptosis, kegg, {}
ENSG00000104365~hsa04210
IKBKB, Apoptosis, kegg, {}
ENSG00000149311~hsa04210
ATM, Apoptosis, kegg, {}
ENSG00000171552~hsa04210
BCL2L1, Apoptosis, kegg, {}
ENSG00000171791~hsa04210
BCL2, Apoptosis, kegg, {}
ENSG00000213341~hsa04210
CHUK, Apoptosis, kegg, {}
ENSG00000004975~hsa04310
DVL2, Wnt signaling pathway, kegg, {}
ENSG00000005339~hsa04310
CREBBP, Wnt signaling pathway, kegg, {}
ENSG00000050748~hsa04310
MAPK9, Wnt signaling pathway, kegg, {}
ENSG00000078304~hsa04310
PPP2R5C, Wnt signaling pathway, kegg, {}
ENSG00000082701~hsa04310
GSK3B, Wnt signaling pathway, kegg, {}
ENSG00000100393~hsa04310
EP300, Wnt signaling pathway, kegg, {}
ENSG00000100888~hsa04310
CHD8, Wnt signaling pathway, kegg, {}
ENSG00000101266~hsa04310
CSNK2A1, Wnt signaling pathway, kegg, {}
ENSG00000105568~hsa04310
PPP2R1A, Wnt signaling pathway, kegg, {}
ENSG00000107643~hsa04310
MAPK8, Wnt signaling pathway, kegg, {}
ENSG00000109339~hsa04310
MAPK10, Wnt signaling pathway, kegg, {}
ENSG00000113575~hsa04310
PPP2CA, Wnt signaling pathway, kegg, {}
ENSG00000113712~hsa04310
CSNK1A1, Wnt signaling pathway, kegg, {}
ENSG00000154229~hsa04310
PRKCA, Wnt signaling pathway, kegg, {}
ENSG00000166949~hsa04310
SMAD3, Wnt signaling pathway, kegg, {}
ENSG00000175387~hsa04310
SMAD2, Wnt signaling pathway, kegg, {}
ENSG00000204435~hsa04310
CSNK2B, Wnt signaling pathway, kegg, {}
ENSG00000050748~hsa04722
MAPK9, Neurotrophin signaling pathway, kegg, {}
ENSG00000070831~hsa04722
CDC42, Neurotrophin signaling pathway, kegg, {}
ENSG00000078900~hsa04722
TP73, Neurotrophin signaling pathway, kegg, {}
ENSG00000082701~hsa04722
GSK3B, Neurotrophin signaling pathway, kegg, {}
ENSG00000097007~hsa04722
ABL1, Neurotrophin signaling pathway, kegg, {}
ENSG00000100030~hsa04722
MAPK1, Neurotrophin signaling pathway, kegg, {}
ENSG00000100906~hsa04722
NFKBIA, Neurotrophin signaling pathway, kegg, {}
ENSG00000102882~hsa04722
MAPK3, Neurotrophin signaling pathway, kegg, {}
ENSG00000104365~hsa04722
IKBKB, Neurotrophin signaling pathway, kegg, {}
ENSG00000107643~hsa04722
MAPK8, Neurotrophin signaling pathway, kegg, {}
ENSG00000108953~hsa04722
YWHAE, Neurotrophin signaling pathway, kegg, {}
ENSG00000109339~hsa04722
MAPK10, Neurotrophin signaling pathway, kegg, {}
ENSG00000164924~hsa04722
YWHAZ, Neurotrophin signaling pathway, kegg, {}
ENSG00000170027~hsa04722
YWHAG, Neurotrophin signaling pathway, kegg, {}
ENSG00000171791~hsa04722
BCL2, Neurotrophin signaling pathway, kegg, {}
ENSG00000185386~hsa04722
MAPK11, Neurotrophin signaling pathway, kegg, {}
ENSG00000171552~hsa05014
BCL2L1, Amyotrophic lateral sclerosis (ALS), kegg, {}
ENSG00000171791~hsa05014
BCL2, Amyotrophic lateral sclerosis (ALS), kegg, {}
ENSG00000185386~hsa05014
MAPK11, Amyotrophic lateral sclerosis (ALS), kegg, {}
ENSG00000204209~hsa05014
DAXX, Amyotrophic lateral sclerosis (ALS), kegg, {}
ENSG00000005339~hsa05016
CREBBP, Huntington's disease, kegg, {}
ENSG00000100393~hsa05016
EP300, Huntington's disease, kegg, {}
ENSG00000112592~hsa05016
TBP, Huntington's disease, kegg, {}
ENSG00000116478~hsa05016
HDAC1, Huntington's disease, kegg, {}
ENSG00000118260~hsa05016
CREB1, Huntington's disease, kegg, {}
ENSG00000169375~hsa05016
SIN3A, Huntington's disease, kegg, {}
ENSG00000185591~hsa05016
SP1, Huntington's disease, kegg, {}
ENSG00000196591~hsa05016
HDAC2, Huntington's disease, kegg, {}
ENSG00000197386~hsa05016
HTT, Huntington's disease, kegg, {}
ENSG00000033800~hsa05160
PIAS1, Hepatitis C, kegg, {}
ENSG00000050748~hsa05160
MAPK9, Hepatitis C, kegg, {}
ENSG00000055332~hsa05160
EIF2AK2, Hepatitis C, kegg, {}
ENSG00000078043~hsa05160
PIAS2, Hepatitis C, kegg, {}
ENSG00000082701~hsa05160
GSK3B, Hepatitis C, kegg, {}
ENSG00000100030~hsa05160
MAPK1, Hepatitis C, kegg, {}
ENSG00000100906~hsa05160
NFKBIA, Hepatitis C, kegg, {}
ENSG00000102882~hsa05160
MAPK3, Hepatitis C, kegg, {}
ENSG00000104365~hsa05160
IKBKB, Hepatitis C, kegg, {}
ENSG00000105229~hsa05160
PIAS4, Hepatitis C, kegg, {}
ENSG00000105568~hsa05160
PPP2R1A, Hepatitis C, kegg, {}
ENSG00000107643~hsa05160
MAPK8, Hepatitis C, kegg, {}
ENSG00000109339~hsa05160
MAPK10, Hepatitis C, kegg, {}
ENSG00000113575~hsa05160
PPP2CA, Hepatitis C, kegg, {}
ENSG00000124762~hsa05160
CDKN1A, Hepatitis C, kegg, {}
ENSG00000131467~hsa05160
PSME3, Hepatitis C, kegg, {}
ENSG00000156475~hsa05160
PPP2R2B, Hepatitis C, kegg, {}
ENSG00000185386~hsa05160
MAPK11, Hepatitis C, kegg, {}
ENSG00000213341~hsa05160
CHUK, Hepatitis C, kegg, {}
ENSG00000221914~hsa05160
PPP2R2A, Hepatitis C, kegg, {}
ENSG00000004975~hsa05200
DVL2, Pathways in cancer, kegg, {}
ENSG00000005339~hsa05200
CREBBP, Pathways in cancer, kegg, {}
ENSG00000033800~hsa05200
PIAS1, Pathways in cancer, kegg, {}
ENSG00000050748~hsa05200
MAPK9, Pathways in cancer, kegg, {}
ENSG00000051180~hsa05200
RAD51, Pathways in cancer, kegg, {}
ENSG00000070831~hsa05200
CDC42, Pathways in cancer, kegg, {}
ENSG00000073756~hsa05200
PTGS2, Pathways in cancer, kegg, {}
ENSG00000078043~hsa05200
PIAS2, Pathways in cancer, kegg, {}
ENSG00000080824~hsa05200
HSP90AA1, Pathways in cancer, kegg, {}
ENSG00000082701~hsa05200
GSK3B, Pathways in cancer, kegg, {}
ENSG00000095002~hsa05200
MSH2, Pathways in cancer, kegg, {}
ENSG00000096384~hsa05200
HSP90AB1, Pathways in cancer, kegg, {}
ENSG00000097007~hsa05200
ABL1, Pathways in cancer, kegg, {}
ENSG00000100030~hsa05200
MAPK1, Pathways in cancer, kegg, {}
ENSG00000100393~hsa05200
EP300, Pathways in cancer, kegg, {}
ENSG00000100644~hsa05200
HIF1A, Pathways in cancer, kegg, {}
ENSG00000100906~hsa05200
NFKBIA, Pathways in cancer, kegg, {}
ENSG00000101109~hsa05200
STK4, Pathways in cancer, kegg, {}
ENSG00000101412~hsa05200
E2F1, Pathways in cancer, kegg, {}
ENSG00000102882~hsa05200
MAPK3, Pathways in cancer, kegg, {}
ENSG00000104365~hsa05200
IKBKB, Pathways in cancer, kegg, {}
ENSG00000105229~hsa05200
PIAS4, Pathways in cancer, kegg, {}
ENSG00000107643~hsa05200
MAPK8, Pathways in cancer, kegg, {}
ENSG00000109339~hsa05200
MAPK10, Pathways in cancer, kegg, {}
ENSG00000112769~hsa05200
LAMA4, Pathways in cancer, kegg, {}
ENSG00000116478~hsa05200
HDAC1, Pathways in cancer, kegg, {}
ENSG00000123374~hsa05200
CDK2, Pathways in cancer, kegg, {}
ENSG00000124762~hsa05200
CDKN1A, Pathways in cancer, kegg, {}
ENSG00000134086~hsa05200
VHL, Pathways in cancer, kegg, {}
ENSG00000135679~hsa05200
MDM2, Pathways in cancer, kegg, {}
ENSG00000139618~hsa05200
BRCA2, Pathways in cancer, kegg, {}
ENSG00000140464~hsa05200
PML, Pathways in cancer, kegg, {}
ENSG00000147889~hsa05200
CDKN2A, Pathways in cancer, kegg, {}
ENSG00000154229~hsa05200
PRKCA, Pathways in cancer, kegg, {}
ENSG00000166949~hsa05200
SMAD3, Pathways in cancer, kegg, {}
ENSG00000169083~hsa05200
AR, Pathways in cancer, kegg, {}
ENSG00000169398~hsa05200
PTK2, Pathways in cancer, kegg, {}
ENSG00000171552~hsa05200
BCL2L1, Pathways in cancer, kegg, {}
ENSG00000171791~hsa05200
BCL2, Pathways in cancer, kegg, {}
ENSG00000171862~hsa05200
PTEN, Pathways in cancer, kegg, {}
ENSG00000175387~hsa05200
SMAD2, Pathways in cancer, kegg, {}
ENSG00000186716~hsa05200
BCR, Pathways in cancer, kegg, {}
ENSG00000196591~hsa05200
HDAC2, Pathways in cancer, kegg, {}
ENSG00000196730~hsa05200
DAPK1, Pathways in cancer, kegg, {}
ENSG00000198793~hsa05200
MTOR, Pathways in cancer, kegg, {}
ENSG00000213341~hsa05200
CHUK, Pathways in cancer, kegg, {}
ENSG00000050748~hsa05210
MAPK9, Colorectal cancer, kegg, {}
ENSG00000082701~hsa05210
GSK3B, Colorectal cancer, kegg, {}
ENSG00000095002~hsa05210
MSH2, Colorectal cancer, kegg, {}
ENSG00000100030~hsa05210
MAPK1, Colorectal cancer, kegg, {}
ENSG00000102882~hsa05210
MAPK3, Colorectal cancer, kegg, {}
ENSG00000107643~hsa05210
MAPK8, Colorectal cancer, kegg, {}
ENSG00000109339~hsa05210
MAPK10, Colorectal cancer, kegg, {}
ENSG00000166949~hsa05210
SMAD3, Colorectal cancer, kegg, {}
ENSG00000171791~hsa05210
BCL2, Colorectal cancer, kegg, {}
ENSG00000175387~hsa05210
SMAD2, Colorectal cancer, kegg, {}
ENSG00000050748~hsa05212
MAPK9, Pancreatic cancer, kegg, {}
ENSG00000051180~hsa05212
RAD51, Pancreatic cancer, kegg, {}
ENSG00000070831~hsa05212
CDC42, Pancreatic cancer, kegg, {}
ENSG00000100030~hsa05212
MAPK1, Pancreatic cancer, kegg, {}
ENSG00000101412~hsa05212
E2F1, Pancreatic cancer, kegg, {}
ENSG00000102882~hsa05212
MAPK3, Pancreatic cancer, kegg, {}
ENSG00000104365~hsa05212
IKBKB, Pancreatic cancer, kegg, {}
ENSG00000107643~hsa05212
MAPK8, Pancreatic cancer, kegg, {}
ENSG00000109339~hsa05212
MAPK10, Pancreatic cancer, kegg, {}
ENSG00000139618~hsa05212
BRCA2, Pancreatic cancer, kegg, {}
ENSG00000147889~hsa05212
CDKN2A, Pancreatic cancer, kegg, {}
ENSG00000166949~hsa05212
SMAD3, Pancreatic cancer, kegg, {}
ENSG00000171552~hsa05212
BCL2L1, Pancreatic cancer, kegg, {}
ENSG00000175387~hsa05212
SMAD2, Pancreatic cancer, kegg, {}
ENSG00000213341~hsa05212
CHUK, Pancreatic cancer, kegg, {}
ENSG00000082701~hsa05213
GSK3B, Endometrial cancer, kegg, {}
ENSG00000100030~hsa05213
MAPK1, Endometrial cancer, kegg, {}
ENSG00000102882~hsa05213
MAPK3, Endometrial cancer, kegg, {}
ENSG00000171862~hsa05213
PTEN, Endometrial cancer, kegg, {}
ENSG00000100030~hsa05214
MAPK1, Glioma, kegg, {}
ENSG00000101412~hsa05214
E2F1, Glioma, kegg, {}
ENSG00000102882~hsa05214
MAPK3, Glioma, kegg, {}
ENSG00000124762~hsa05214
CDKN1A, Glioma, kegg, {}
ENSG00000135679~hsa05214
MDM2, Glioma, kegg, {}
ENSG00000147889~hsa05214
CDKN2A, Glioma, kegg, {}
ENSG00000154229~hsa05214
PRKCA, Glioma, kegg, {}
ENSG00000171862~hsa05214
PTEN, Glioma, kegg, {}
ENSG00000198793~hsa05214
MTOR, Glioma, kegg, {}
ENSG00000005339~hsa05215
CREBBP, Prostate cancer, kegg, {}
ENSG00000080824~hsa05215
HSP90AA1, Prostate cancer, kegg, {}
ENSG00000082701~hsa05215
GSK3B, Prostate cancer, kegg, {}
ENSG00000096384~hsa05215
HSP90AB1, Prostate cancer, kegg, {}
ENSG00000100030~hsa05215
MAPK1, Prostate cancer, kegg, {}
ENSG00000100393~hsa05215
EP300, Prostate cancer, kegg, {}
ENSG00000100906~hsa05215
NFKBIA, Prostate cancer, kegg, {}
ENSG00000101412~hsa05215
E2F1, Prostate cancer, kegg, {}
ENSG00000102882~hsa05215
MAPK3, Prostate cancer, kegg, {}
ENSG00000104365~hsa05215
IKBKB, Prostate cancer, kegg, {}
ENSG00000118260~hsa05215
CREB1, Prostate cancer, kegg, {}
ENSG00000123374~hsa05215
CDK2, Prostate cancer, kegg, {}
ENSG00000124762~hsa05215
CDKN1A, Prostate cancer, kegg, {}
ENSG00000135679~hsa05215
MDM2, Prostate cancer, kegg, {}
ENSG00000169083~hsa05215
AR, Prostate cancer, kegg, {}
ENSG00000171791~hsa05215
BCL2, Prostate cancer, kegg, {}
ENSG00000171862~hsa05215
PTEN, Prostate cancer, kegg, {}
ENSG00000198793~hsa05215
MTOR, Prostate cancer, kegg, {}
ENSG00000213341~hsa05215
CHUK, Prostate cancer, kegg, {}
ENSG00000100030~hsa05216
MAPK1, Thyroid cancer, kegg, {}
ENSG00000102882~hsa05216
MAPK3, Thyroid cancer, kegg, {}
ENSG00000004975~hsa05217
DVL2, Basal cell carcinoma, kegg, {}
ENSG00000082701~hsa05217
GSK3B, Basal cell carcinoma, kegg, {}
ENSG00000100030~hsa05218
MAPK1, Melanoma, kegg, {}
ENSG00000101412~hsa05218
E2F1, Melanoma, kegg, {}
ENSG00000102882~hsa05218
MAPK3, Melanoma, kegg, {}
ENSG00000124762~hsa05218
CDKN1A, Melanoma, kegg, {}
ENSG00000135679~hsa05218
MDM2, Melanoma, kegg, {}
ENSG00000147889~hsa05218
CDKN2A, Melanoma, kegg, {}
ENSG00000171862~hsa05218
PTEN, Melanoma, kegg, {}
ENSG00000100030~hsa05219
MAPK1, Bladder cancer, kegg, {}
ENSG00000101412~hsa05219
E2F1, Bladder cancer, kegg, {}
ENSG00000102882~hsa05219
MAPK3, Bladder cancer, kegg, {}
ENSG00000124762~hsa05219
CDKN1A, Bladder cancer, kegg, {}
ENSG00000135679~hsa05219
MDM2, Bladder cancer, kegg, {}
ENSG00000147889~hsa05219
CDKN2A, Bladder cancer, kegg, {}
ENSG00000196730~hsa05219
DAPK1, Bladder cancer, kegg, {}
ENSG00000097007~hsa05220
ABL1, Chronic myeloid leukemia, kegg, {}
ENSG00000100030~hsa05220
MAPK1, Chronic myeloid leukemia, kegg, {}
ENSG00000100906~hsa05220
NFKBIA, Chronic myeloid leukemia, kegg, {}
ENSG00000101412~hsa05220
E2F1, Chronic myeloid leukemia, kegg, {}
ENSG00000102882~hsa05220
MAPK3, Chronic myeloid leukemia, kegg, {}
ENSG00000104365~hsa05220
IKBKB, Chronic myeloid leukemia, kegg, {}
ENSG00000116478~hsa05220
HDAC1, Chronic myeloid leukemia, kegg, {}
ENSG00000124762~hsa05220
CDKN1A, Chronic myeloid leukemia, kegg, {}
ENSG00000135679~hsa05220
MDM2, Chronic myeloid leukemia, kegg, {}
ENSG00000147889~hsa05220
CDKN2A, Chronic myeloid leukemia, kegg, {}
ENSG00000166949~hsa05220
SMAD3, Chronic myeloid leukemia, kegg, {}
ENSG00000171552~hsa05220
BCL2L1, Chronic myeloid leukemia, kegg, {}
ENSG00000186716~hsa05220
BCR, Chronic myeloid leukemia, kegg, {}
ENSG00000196591~hsa05220
HDAC2, Chronic myeloid leukemia, kegg, {}
ENSG00000213341~hsa05220
CHUK, Chronic myeloid leukemia, kegg, {}
ENSG00000033800~hsa05222
PIAS1, Small cell lung cancer, kegg, {}
ENSG00000073756~hsa05222
PTGS2, Small cell lung cancer, kegg, {}
ENSG00000078043~hsa05222
PIAS2, Small cell lung cancer, kegg, {}
ENSG00000100906~hsa05222
NFKBIA, Small cell lung cancer, kegg, {}
ENSG00000101412~hsa05222
E2F1, Small cell lung cancer, kegg, {}
ENSG00000104365~hsa05222
IKBKB, Small cell lung cancer, kegg, {}
ENSG00000105229~hsa05222
PIAS4, Small cell lung cancer, kegg, {}
ENSG00000112769~hsa05222
LAMA4, Small cell lung cancer, kegg, {}
ENSG00000123374~hsa05222
CDK2, Small cell lung cancer, kegg, {}
ENSG00000169398~hsa05222
PTK2, Small cell lung cancer, kegg, {}
ENSG00000171552~hsa05222
BCL2L1, Small cell lung cancer, kegg, {}
ENSG00000171791~hsa05222
BCL2, Small cell lung cancer, kegg, {}
ENSG00000171862~hsa05222
PTEN, Small cell lung cancer, kegg, {}
ENSG00000213341~hsa05222
CHUK, Small cell lung cancer, kegg, {}
ENSG00000100030~hsa05223
MAPK1, Non-small cell lung cancer, kegg, {}
ENSG00000101109~hsa05223
STK4, Non-small cell lung cancer, kegg, {}
ENSG00000101412~hsa05223
E2F1, Non-small cell lung cancer, kegg, {}
ENSG00000102882~hsa05223
MAPK3, Non-small cell lung cancer, kegg, {}
ENSG00000147889~hsa05223
CDKN2A, Non-small cell lung cancer, kegg, {}
ENSG00000154229~hsa05223
PRKCA, Non-small cell lung cancer, kegg, {}
</pre></dd></dl>

