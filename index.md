---
title: Rbbt
layout: default
tagline: Ruby bioinformatics toolkit
---


What is Rbbt?
-------------

Rbbt stands for "Ruby Bioinformatics Toolkit". It is a framework for software
development in bioinformatics. It covers three aspects:

* Developing functionalities
* Making them as widely accessible as possible
* Integrating them with one another

It was intended initially to hold different low level tools that for the basis
of most bioinformatics work: parsing and tidying data, gathering resources,
organizing the sequential production of results for reusable/reproducible work.
The framework provides incentives to adhere to several reasonable standards that
improve reusability and interoperability and has thus resulted in a very
comprehensive set of functionalities that now form one of the most ambitions
bioinformatics frameworks available.


What are the main features in Rbbt?
-------------

The Rbbt framework has many many features. The following are some of the most
important:

* TSV file manipulation, indexing and traversal with native programmatic
  support for persistence, map-reduce, indexing, slicing, reordering, sorting,
  pagination, semantic interpretation of file headers, etc
* Resource management with cross-application sharing, claiming production,
  updating, versioning, etc
* Transparent out of the box top-of-the-line performance with no loading time
  across all functionalities owing to automatic database generation using a
  dozen different database backends ranging from key-value stores and B-trees
  to sorted fixed-width indices with binary search support for point and range
  based queries, with support for sharding, indexing, etc
* Workflow definition and enactment, with map-reduce, streaming,
  cross-workflow/cross-host dependencies for functionality syndication across
  departments/institutions, incremental/intelligent updates,
  orthogonal command-line/web-page/REST/SOAP/API access automatically
  provided, extensible web templating, etc
* Full-blown templating engine for HTML/CSS/javascript based on
  HAML/SASS-Compass/JQuery, with a plugin approach to functionality integration
  and a state-of-the-art semantic-based live report generation
* Knowledge representation standard that allow for new approaches for data
  integration and exploration through interactive graphs, and plots, and
  reports that allow the user to follow leads and examine the evidence to
  support connections between different entities
* Stream oriented processing with transparent support for working with files,
  sockets, remote urls, workflow dependencies, compressed files, support for
  seekable compressed streams using a native implementation of BGZF with
  in-situ incremental index generation. Complex native concurrency support
  using event driven programming for multi-processing streaming cascades
* R integration using direct library calls (RSRuby), shared server (Reval) or
  shell-out (R CMD). Deep integration for model fitting and plotting of SVGs with
  painless state-of-the-art D3js integration
* Enough syntactic sugar to make a cake thanks to (abused) ruby meta-programming and the
  principle of convention-over-configuration

Using these features, dozens of workflows have been produced; serving
functionalities, resources, knowledge bases, and reports.

Where has Rbbt been used?
-------------------------

Rbbt has been used to power several applications, either in their entirety of
parts of it, like the workflow management:

* [SENT](http://sent.dacya.ucm.es/): semantic features in text
* [BioNMF](http://bionmf.dacya.ucm.es/): Non-negative matrix factorization in biology
* [MARQ](http://marq.dacya.ucm.es/): microarray-rank query
* [Genecodis](http://genecodis.cnb.csic.es/): Gene annotation co-occurrence discovery
* [3DEM Loupe](http://3demloupe.cnb.csic.es): Normal mode analysis of dynamics of structures from electron microscopy
* [TaLasso](http://talasso.cnb.csic.es/): Quantification of miRNA-mRNA interactions
* [KinMut](http://wkinmut.bioinfo.cnio.es/): Pathogenicity predictions of kinase mutations
* [Structure-PPI](http://structureppi.bioinfo.cnio.es/): Maps mutations to
  structural features in several databases using PDBs 

These applications have driven the development of the framework over the
years, the code used in them has been re-factored several times since

Where is it used now?
---------------------

My current interest is in cancer genome analysis. Work in this area has
stimulated the development of several new concepts, such as the Entity
subsystem, a novel approach developed to alleviate the complex challenges of
integration.


The StudyExplorer is our current flagship application. I can be adapted to different
scenarios and several instances of it serves different groups in our institution. An
example deployment is [ICGC Scout](http://se.bioinfo.cnio.es), that provides access to 
all cancer studies from ICGC and TCGA and offers a wide array of functionalities.

What is in it?
--------------

Well, a large number of workflows have been developed:

* [Sequence](https://github.com/Rbbt-Workflows/sequence): functionalities regarding genomic analysis, such as mutation consequence analysis
* [MutEval](https://github.com/Rbbt-Workflows/mut_eval): evaluation of pathogenicity of variants (it actually interfaces with other systems)
* [Structure](https://github.com/Rbbt-Workflows/structure): functionalities for structural analysis of proteins
* [Enrichment](https://github.com/Rbbt-Workflows/enrichment): over-representation and rank-based methods for enrichment analysis, supporting: Kegg, GO, Nature Curated Cancer Pathways, Reactome, Biocarta, PFAM, Transfac, ect
* and many [more](https://github.com/Rbbt-Workflows)

How can I try it?
-----------------

To try out workflows the easiest way is to use them remotely. If you manage to
install Ruby and the gems `rbbt-util` and `rbbt-rest` you can try the following
examples; they should give you a taste of how it works.

See available tasks for the Structure workflow; and the help for a particular task

{% highlight bash %}
rbbt workflow task http://se.bioinfo.cnio.es/Structure -h
rbbt workflow task http://se.bioinfo.cnio.es/Structure -h annotate
{% endhighlight %}


Translate gene names to Ensembl Gene ID

{% highlight bash %}
rbbt workflow task http://se.bioinfo.cnio.es/Translation tsv_translate -g TP53,MDM2,RB1
{% endhighlight %}

Annotated coding variants from VCF file

{% highlight bash %}
rbbt workflow task http://se.bioinfo.cnio.es/Sequence mutated_isoforms_fast -m <vcf.file> --vcf
{% endhighlight %}

Find up/down regulated genes in a GEO dataset for a particular contrast...

{% highlight bash %}
rbbt workflow task http://se.bioinfo.cnio.es/GEO up_genes -d GDS4455 -m "genotype/variation=RhoGDI2" -tg
rbbt workflow task http://se.bioinfo.cnio.es/GEO down_genes -d GDS4455 -m "genotype/variation=RhoGDI2" -tg
{% endhighlight %}

You can also use `wget` or `curl`, but remember to specify the `_format` as
`raw` or `json`

{% highlight bash %}
wget "http://se.bioinfo.cnio.es/Sequence/mutated_isoforms?mutations=7:31003700:T&_format=raw" --quiet -O -
{% endhighlight %}

How can I benefit?
------------------

As a user by using the applications that it powers :) As a developer, by taking
its code apart, copying the ideas, stealing shamelessly the implementations,
or even by using the framework as it is supposed to be used. 

The extent of the functionalities and the conceptual depth of the underlaying
design makes approaching the Rbbt framework daunting. I'm spend many work
sprints improving the accessibility of the functionalities, but few on
documenting the core. I believe a good programmer with a little guidance can
easily find code examples in workflows and test sets that illustrate the myriad
of ways the framework can be used. I have little time left to document more,
but I'll be willing to lend a hand to a motivated programmer if he find this
interesting.

Examples and tutorials
----------------------
* [Introduction](tutorial/introduction)
* [Background](tutorial/background)
* [Command-line](tutorial/commandline)
* [Install](tutorial/install)
* [TSV](tutorial/TSV)
* [TSV#traversal (map-reduce)](tutorial/map_reduce)
* [Resource](tutorial/Resource)
* [Workflow](tutorial/Workflow)
* [Knowledge Base](tutorial/knowledge_base)

What is up?
-----------

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
