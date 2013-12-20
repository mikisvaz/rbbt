---
title: Background
layout: default
tagline: Background
---

# Background

Wet lab biologist follow protocols in their work. These are like recipes that
render particular results. Their work is expected to be reproducible in other
labs, which is achieved by documenting these protocols in detail.

In bioinformatics we should draw a parallel. Fortunately, in computer science
the protocols are implicitly described in excruciating detail through the
source code. Unfortunately bioinformatics protocols are rarely in code
entirely: data files are downloaded and tidy up manually, tasks are scheduled
manually, infrastructure results are placed in arbitrary locations. The
consequence is that the standards in code reusability and reproducibility are
still quite low. Most difficulties strive for technical issues, which I
set-out to solve in this framework.

My approach is to lay-out a complete approach to software development tailored
for bioinformatics. This approach should make sure that the software produced
is as useful as possible without increasing the work for the developer. To
achieve this, we provide an complete infrastructure that has two objectives:
make development easier and make the resulting software more useful. In other
words, the framework should not impose on the developer, but it should help
first and foremost its current development. 

## Protocols, recipes and Workflows

A protocol or recipe can be though of a number of tasks that have to be
performed. These tasks might depend on other being completed first, these
dependencies stablish a sort of workflow. For bioinformatics we propose the
following constrains: each task produces a result file, the result file depends
on the results of previous tasks, and the inputs the task receives.
Furthermore, the same task, with the same inputs should always produce the same
results. 

Our approach has a number of advantages. First, the idea of tasks producing
files parallels with a common pattern in computer science dating back to the
dawn of compiler technology. In fact the Makefile tool works in this way, it
specifies how different object files are compiled from their sources, and how
they are packaged in libraries and executables. Makefiles however do not
support parametrization through variables very easily, but again this is just a
technical issue. Given the set of parameters collectively required by all tasks
involved in a workflow, the result of each workflow is completely specified,
thus it is possible to reuse these partial results intelligently and update
them incrementally when parameters change; it is easy to determine if the
result of a task changes based on its parameters or in the parameters of tasks
that it depends on.

In brief, all that is needed to specify a recipe is the task themselves, a
description of their inputs and the dependency graph they form. The `Workflow`
subsystem takes care of all these details, providing a simple, succinct, and
expressive way to define these tasks. Workflows are declared though a
completely programmatic API, unlike other workflow enactment tools which
require XML configuration files. Having a completely programmatic way to define
workflows makes them easier to define, since the are not authoring tools
required to write XML or configuration file, the syntax is clear, since is just
Ruby code, and furthermore, workflows themselves can be natively defined from
other code. 

Most of the time spent in developing a project in bioinformatics is devoted to
gathering and tidying data, and preparing the infrastructure that will support
the analysis. Each project has its own requirements, but often they are common
to many, and even different tasks may have strong similarities when it comes
down to the process itself. Let us consider for instance the problem of
identifier translation: different data bases refer to the same entities using
different identifiers, the most clear case being genes. Once we device a
solution for identifier translation we would like to reuse it in any further
projects. This entails: writing the code, placing it where it can be found
later on, figuring a way to access it from a different code base. The workflow
system provides a solution for all these. Including support for all the
different ways in which you could want to access your functionalities:

* programmatically from other scripts
* from the command-line
* using a user friendly web interface
* remotely through a REST web server

In fact the remote web server can be configured transparently as a back-end for
the programmatic and command-line interfaces. 

The `Workflow` subsystem in Rbbt, thanks to is simplicity of design and its
generality is at the center of the entire framework, and its responsibilities
surpass just powering the execution of workflow tasks, as we will see later.

However, in bioinformatics the code is not our only concern; what is often most
challenging is managing the data and the infrastructures that support the
different functionalities.

## TSV files and persistence

Most tasks in bioinformatics involve processing tab separated value (TSV)
files. These files have several important characteristics:

* The structure information as keys associated to values. Keys are the first
  column of the TSV files and the values are the rest
* Keys are entities (genes, proteins, samples), and thus, each line of the TSV
  file represents information on one entity
* The fact that they are line-oriented makes them specially suitable to be
  processed with UNIX tools, like `sed`, `grep` or `awk`.

This scheme matches they way we usually query information in biofinformatics,
by making inquiries about particular aspects (values) of a given entity (key).
It is thus crucial to be able to manage these files efficiently. Most files in
bioinformatics are TSV files, and while not all match our standard, for
instance the key might not be the first column, they can usually be classified
into four classes:

* Single: there is only a single value, that represents a particular aspect
* List: there is a list of values, each representing a different aspect
* Flat: there is a list of values, each representing different values for the
  same aspect (transcripts of a gene)
* Double: there are lists of lists, each representing different values of
  different aspects

The `TSV` subsystem is perhaps the most important piece of code in the
framework, as I have reduced all data management to TSV files. These files can
be loaded into a Hash object, a native data structure in Ruby with extensive
support. However, in Rbbt these Hash objects are "enhanced" in several ways.

When accessing values of `list` and `double` TSV files, the resulting array
is annotated with the names of the columns of the file, to allow queries such
as these:

{% highlight ruby %}

tsv = Organism.gene_positions("Hsa").tsv

tsv[gene]["Chromosome Name"]
tsv[gene]["Chromosome Start"]
tsv[gene]["Chromosome Position"]

{% endhighlight %}

TSV files come in many sizes, from files with a few tens of lines to files with
several million entries. Parsing these files and storing them in memory becomes
problematic when they are very large. For this reason, the `TSV` subsystem in
Rbbt can `persist` them, that is, open them into an efficient TokyoCabinet
key-value store, and make the Hash transparently delegate the access to the
data to the database. We will discuss in a while the `Resource` submodule, but
suffice to say that when these files are open with persistence, they key-values
store is set on an specific location of the file-system so that any other
program that attempts to open the same file in the same way will immediately
and transparently reuse the same key value store.

On top of these are a wide array of functionalities to manipulate these files
from sub-setting the values or columns of the file, intelligent merging them to
one another, even automatically translating entities from one format to another
to match them, building inverse indices, etc.

By using TSV files we completely avoid defining a database scheme; each TSV
contains information that is access independently when needed, they do not have
to agree on any aspect, this tailoring is done in the application level to fit
the need of the current analysis. For instance, a PPI database might use
protein identifiers to list the partners in the interaction, in some cases we
might want to translate them to gene identifiers and work with them as genes
and in other cases we might need to retain the distinction on the particular
isoform that is listed in the interaction. In this approach, we do not need to
make a decision before hand. Good performance is achieved with the key-value
stores, which are created on demand to serve specifically the query that you
need, and then efficiently reused.

TokyoCabinet key-value stores are just one type of persistence available, the
`Persist` submodule is more general than that and can persist the result of any
block of Ruby code in different formats: integer, float, boolean, string,
array, TSV, YAML or native Marshal. These simple formats are enough to
represent all our data efficiently. The Persist submodule is used across the
whole framework, from persisting TSV files, as we have just seen, to persisting
the results of workflow tasks, web site pages, resources, etc., and its a very
useful tool in any script.

##Resources

Managing resources is, as I mentioned before, one of the most time consuming
steps in bioinformatics. It entails gathering data files from authoritative
sources, tidying them up for our use, placing them in specific locations where
they can be found by our scripts.  It also entails building databases and
indices that support efficient queries over the data, and it could even require
downloading, compiling and configuring third party software packages and
libraries.

The Rbbt framework offers the `Resource` subsystem to encapsulate resource
management and broker access from scripts. It does so by solving several
problems. The first one is resource location. When accessing a resource we do
not want to hardcode the path into the code, specially an absolute path.
Relative paths are better that absolute ones, and software packages often use
resources on directories relative to them. However, if several pieces of
software require access to the same resource this approach is inefficient and
leads to duplicate resources. What Rbbt provides is a declarative way to access
resources. Coming back to the example of identifier translation, the file
listing all the translations between identifiers is identified as follows
`Organism.identifiers("Hsa/jan2013")`, which results in the 'pseudo-path'
`share/organisms/Hsa/jan2013/identifiers`. As you can see the declaration is
fairly succinct, it includes the namespace of the resource, 'Organism', the
name of the file, and the organism (Hsa for *H* *sa*piens) and particular build
(jan2013, specifying no build will use all the current information). The
convention for organism names is taken from KEGG (Mmu for *M*us *mu*sculus),
the convention for build dates from Ensembl, since we get the most basic
genomic information from there.  

I use the term 'pseudo-path' to refer to the fact that, even though it looks
like a relative path, when it comes down to opening the file the Resource
subsystem will attempt to locate it in several places:

* relative: `./share/organisms/Hsa/jan2013/identifiers`
* lib: `{library-root}/share/organisms/Hsa/jan2013/identifiers`
* user: `~/.rbbt/share/organisms/Hsa/jan2013/identifiers`
* local: `/usr/local/share/rbbt/organisms/Hsa/jan2013/identifiers`
* global: `/usr/share/rbbt/organisms/Hsa/jan2013/identifiers`

Whichever file is found first is openend. This approach allows resources to be
specified globaly for an entire environment but still allow particular users or
scripts to redefine them. As we will see in the section on the web interfaces,
this forms the basis of our modular approach to application development.  The
'{library-root}' is calculated from the file that has requested the file, the
path of the file is extracted and then traversed back to the parent directory
that contains the sub-directory `lib`. Thus, by creating a `lib` directory
inside a project you 'root' the Resource file system allowing access to all
other resources bellow it.

If none of alternative files exist, the Resource subsystem initiates a process
original to rbbt: resource claiming. Some of the resources used in Rbbt come
packaged with the code, but these are usually just configuration files or small
data files. In general all resources are `claimed`, meaning that a particular
module of the framework takes responsability for producing the file. In the
case of the `share/organisms/Hsa/jan2013/identifiers`, the `Organism` module
has placed a claim for that file, which is either a URL to a file, a script to
install some software (rbbt has its own very simple software management
subsystem), or more generally a block of code. In this way the claim consists
of instructions to generate the file. When a resource is produced on-demand it
is placed on the `user` location. In the case of the identifier file, the claim
consists on connection to BioMart, making use of archived versions to access
the correct build.

In summary, translating a list of gene identifiers from 'Ensembl Gene ID' to 'Associated
Gene Name' can be done as follows:


{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/sources/organism'

genes = %w(ENSG00000111245 ENSG00000215375 ENSG00000065534)

tsv = Organism.identifiers("Hsa").index :persist => true,
    :target => "Associated Gene Name", :fields => ["Ensembl Gene ID"] 

genes.each do |gene|
  puts [gene, tsv[gene]] * " => "
end
 
{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
ENSG00000111245 => MYL2
ENSG00000215375 => MYL5
ENSG00000065534 => MYLK
</pre></dd></dl>

However the `Translation` workflow offers a simpler interface.

##Entities

Another novelty of the Rbbt is its treatment of entities. Programmatically we
would like to have objects representing, for instance, genes, and be able to
query their properties, such as `gene.COSMIC_mutations` to retrievel all
somatic variants annotated in COSMIC. One alternative is to crete a `Class`
for genes that implements all these properties. However, this forces that all
scripts agree in the same class hierarchy, and that damages reusability and
inter-connectivity between functionalities. Our approach avoids this using
Ruby meta-programming functionalities.

In Rbbt entities are defined as things that can be subject of investigation and
that can be *unambiguously* identified. This means that all that is required is
that entities can be identified, so a `String` object containing the identifier
of the entity should suffice. Functionalities in Rbbt then work with entities
as just mere strings, however, they are `enhanced`, just like hashes containing
TSV files are `enhanced`, by extending them at run time with additional
properties. 

The first of these 'enhancements' are `Annotations`. These are values that are
associated with the entity that further qualify them. Take genes for instance,
the Ensembl ID "ENSG00000116478" reffers to the gene "HDAC1", that much seem
clear, however, if we where to query for its chromosomal location we would
realize that the identifier alone does not suffice. In fact, when it comes down
to it, the HDAC1 gene as we knew it in May 2009 is different than the same gene
as we knew it in January 2013, many of its properties have changed. For many
applications this subtleties have no consequence, but for others it does not.
In Rbbt the `String` object containing "ENSG00000116478" is extended with the
`annotation` `organism`, which specifies the organism and build of the gene,
for instance "Hsa" for the most current version of the gene in Homo sapiens, or
"Hsa/may2009" and "Hsa/jan2013" for the version of the gene as it corresponds
to the hg18 and hg19 builds. I recommend always specifiying a build to avoid
inconsistencies that could come up when resources are requested at different
points. In addition to the organism, genes are annotated as well with the
`format` annotation, which specifies the identifier format used, in this case
"Ensembl Gene ID".

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/workflow'
Workflow.require_workflow "Genomics"
require 'rbbt/entity/gene'

gene = Gene.setup("ENSG00000116478", 
  :format => "Ensembl Gene ID", :organism => "Hsa/jan2013")

puts "Gene id: " << gene

puts "Gene annotations" << gene.info.inspect

puts "Gene name: " << gene.name
puts "Gene name annotations" << gene.name.info.inspect

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Gene id: ENSG00000116478
Gene annotations{:format=>"Ensembl Gene ID", :organism=>"Hsa/jan2013", :annotation_types=>[Gene]}
Gene name: HDAC1
Gene name annotations{:format=>"Associated Gene Name", :organism=>"Hsa/jan2013", :annotation_types=>[Gene]}
</pre></dd></dl>

Since annotations are 'added' to strings, then can be passed around without the
need for different scripts or portions of the code that will process them to
agree on how the gene entity is defined or even be aware of the Entity
subsystem at all. 

New entities can be defined easily from at any point. The following example
illustrates how the `Gene` entity is defined in the `Genomics` workflow. I've
used a different name, `MyGene`, to make clear that we are creating a new type
of entity; however, one can extend entities that already exist, so that several
pieces of code can define the same entity and each will use the properties and
annotations it requires without having to be aware of what the other piece
declared--except of course if both define properties with the same name, which
is why one must use names as precise and descriptive as possible.

{% highlight ruby %}
require 'rbbt-util'
require 'rbbt/entity'
require 'rbbt/sources/organism'

module MyGene
  extend Entity
  annotation :format, :organism

  property :name => :array2single do
    puts "Executing property for: #{self.inspect}"
    Organism.identifiers(organism).index(:persist => true, 
    :target => "Associated Gene Name", :fields => [format]).values_at *self
  end

end

genes = %w(ENSG00000163359 ENSG00000148082 ENSG00000168036)
MyGene.setup(genes, :format => "Ensembl Gene ID", :organism => "Hsa/jan2013")

genes.each do |gene|
  puts [gene, gene.name] * " => "
end

puts "All names: " << genes.name * ", "

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Executing property for: ["ENSG00000163359", "ENSG00000148082", "ENSG00000168036"]
ENSG00000163359 => COL6A3
ENSG00000148082 => SHC3
ENSG00000168036 => CTNNB1
Executing property for: ["ENSG00000163359", "ENSG00000148082", "ENSG00000168036"]
All names: COL6A3, SHC3, CTNNB1
</pre></dd></dl>

Entities have, in addition to these annotations that further qualify them, a
number of additional features. An array of strings can have entity annotations,
which are transfered to the individual strings--the genes themselves-- at the
moment they are access, as we just saw in the previous example. In that example
we also see how the `name` property is declared as `array2single` meaninig that
it will be executed for the complete array, the result saved, and then each
element will take is value from that collective result, even when the property
is queried for a/each particular string inside the array. This mode of
operation can improve performance without adding any further considerations to
the user. 

To make things even easier for the user, the TSV subsystem has 'hooks' for the
Entity subsystem, so that it recognizes fields containing entities and sets
them up automatically.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/entity'
require 'rbbt/sources/organism'

module MyGene
  extend Entity
  annotation :format, :organism

  property :name => :array2single do
    Organism.identifiers(organism).index(:persist => true, 
    :target => "Associated Gene Name").values_at *self
  end

end

text=<<-EOF
#MyGene\tValue
ENSG00000163359\t1
ENSG00000148082\t2
EOF

tsv = TSV.open(StringIO.new(text), :type => :single, :namespace => "Hsa/jan2013")

tsv.each do |gene, value|
  puts [gene.name, value] * ": "
end

puts "Gene annotations: " << tsv.keys.info.inspect

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
COL6A3: 1
SHC3: 2
Gene annotations: {:organism=>"Hsa/jan2013", :format=>"MyGene", :annotation_types=>[MyGene], :annotated_array=>true}
</pre></dd></dl>

As you can see in this example, the `MyGene` header was recognized in the TSV
file and associated with the entity type we just defined. This example is not
very nice, since it incorrectly associated the genes with the format "MyGene",
which is no real format; note that for that reason in translating genes we do
not specify the source format (as the `:fields` argument) but use all available
formats in the file. The following example fixes this by adding specifically a
some formats to recognize. In the real `Gene` class the recognized headers are all
possible formats in the `Organism.identifiers({organism})` file.


{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/entity'
require 'rbbt/sources/organism'

module MyGene
  extend Entity
  annotation :format, :organism
  self.format = ["Ensembl Gene ID", "Associated Gene Name"]

  property :name => :array2single do
    Organism.identifiers(organism).index(:persist => true, 
    :target => "Associated Gene Name", :fields => [format]).values_at *self
  end

end

text=<<-EOF
#Ensembl Gene ID\tValue
ENSG00000163359\t1
ENSG00000148082\t2
EOF

tsv = TSV.open(StringIO.new(text), :type => :single, :namespace => "Hsa/jan2013")

tsv.each do |gene, value|
  puts [gene.name, value] * ": "
end

puts "Gene annotations: " << tsv.keys.info.inspect

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
COL6A3: 1
SHC3: 2
Gene annotations: {:organism=>"Hsa/jan2013", :format=>"Ensembl Gene ID", :annotation_types=>[MyGene], :annotated_array=>true}
</pre></dd></dl>

Note also in the previous examples how we need to specify a `namespace` for the
TSV file, so that the Entity subsystem can use it as the organism for the
genes.
