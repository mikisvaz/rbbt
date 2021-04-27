---
title: Rbbt
layout: default
tagline: Ruby bioinformatics toolkit
---

In a hurry?
-------------

```bash
wget "{{ site.singularity_image_url }}" -O ~/rbbt.singularity.img
alias rbbt='singularity exec -e ~/rbbt.singularity.img rbbt'
rbbt
```

What is Rbbt?
-------------

Rbbt stands for "Ruby Bioinformatics Toolkit". 

It was intended originally as my personal bag-of-tricks and evolved over the years into one
of the most comprehensive development frameworks, at least to my knowledge.

It features tools that form the basis of most bioinformatics work: 

* parsing and tidying data
* gathering and setting up resources like software tools and databases
* organizing the sequential production of results for reusable/reproducible work
* producing reports to share with collaborators
* packaging interoperable functionalities into pluggable modules

The framework provides incentives to adhere to several reasonable standards
that improve reusability and interoperability.


What are the main features in Rbbt?
-------------

Many of the features of Rbbt are organized around four large subsystems:

* *Workflows*: A fully functional workflow enactment system like nextflow or
  cromwell, but with more advanced features. Rbbt has many workflows
  implementing functionalities from different areas of bioinformatics.
* *TSV files*: Tab separated value files are the most versatile file format in
  bioinformatics, and Rbbt has plenty of functionalities to manipulate, index,
  traverse, persist, slice, reorder, sort, paginate and add semantics to them.
* *Resource management*: Rbbt provides very succinct instructions to
  automatically gather, setup and configure data and software resources
* *HTML and REST*: All Rbbt workflows are provided HTML interfaces as well as
  remote execution capabilities through REST. Rbbt has its own concept for the
  design of web applications that greatly cuts down development time.

Where has Rbbt been used and where is it used now?
-------------------------

Rbbt has been used in dozens of applications and projects in the last decade or
so, including drug response analysis, text-mining, functional enrichment
analyses, etc. Some of these developments have been discontinued and are not
maintained, but they have all contributed to define the code base in Rbbt; many
should still work, or can be made to work again, or can be picked for parts. 

Currently the focus is on delivering workflows for genomics analyses that range
from alignment and variant calling to functional interpretation in
investigating clonal evolution, defining combinatorial drug therapies,
designing cancer vaccines, etc.

What is in it?
--------------

A large number of workflows have been developed:

* [HTS](https://github.com/Rbbt-Workflows/HTS): High throughput sequencing functionalities (DNA and RNA-Seq), like alignment and variant calling
* [Translation](https://github.com/Rbbt-Workflows/translation): functionalities to translate gene and protein identifiers across different formats
* [Sequence](https://github.com/Rbbt-Workflows/sequence): functionalities regarding genomic analysis, such as mutation consequence analysis
* [Structure](https://github.com/Rbbt-Workflows/structure): functionalities for structural analysis of proteins
* [Enrichment](https://github.com/Rbbt-Workflows/enrichment): over-representation and rank-based methods for enrichment analysis, supporting: Kegg, GO, Nature Curated Cancer Pathways, Reactome, Biocarta, PFAM, Transfac, ect
* and many [more](https://github.com/Rbbt-Workflows)

How can I try it?
-----------------

To try out workflows one easy way is to use them remotely. For example, to see
available tasks for the Structure workflow; and the help for a particular task

{% highlight bash %}
rbbt workflow task https://rbbt.bsc.es/Sequence -h
rbbt workflow task https://rbbt.bsc.es/Sequence -h mutated_isoforms_fast
{% endhighlight %}


Translate gene names to Ensembl Gene ID

{% highlight bash %}
rbbt workflow task https://rbbt.bsc.es/Translation tsv_translate -g TP53,MDM2,RB1
{% endhighlight %}

Annotated coding variants from VCF file

{% highlight bash %}
rbbt workflow task https://rbbt.bsc.es/Sequence mutated_isoforms_fast -m <vcf.file> --vcf
{% endhighlight %}

You can also use `wget` or `cURL`, but remember to specify the `_format` as
`raw` or `json`. Both `POST` and `GET` are accepted.

{% highlight bash %}
wget "https://rbbt.bsc.es/Sequence/mutated_isoforms?mutations=7:31003700:T&organism=Hsa/feb2014&_format=raw" --quiet -O -
{% endhighlight %}

If you want to specify any inputs as files, you can use cURL:

{% highlight bash %}
curl -H "Expect:" -L http://rbbt.bsc.es/Sequence/mutated_isoforms_fast -F "_format=raw" -F "mutations=@<file>" -F "organism=Hsa/feb2014"
{% endhighlight %}

Note the -H "Expect", which is required for some reason

How can I benefit?
------------------

As a user by using the applications that it powers :) As a developer, by taking
its code apart, copying the ideas, stealing shamelessly the implementations,
or even by using the framework as it is supposed to be used. 

The extent of the functionalities and the conceptual depth of the underlaying
design makes approaching the Rbbt framework daunting. I've spent many work
sprints improving the accessibility of the functionalities, but few on
documenting the core. I believe a good programmer with a little guidance can
easily find code examples in workflows and test sets that illustrate the myriad
of ways the framework can be used. I have little time left to document more,
but I'll be willing to lend a hand to a motivated programmer if he find this
interesting.

Examples and tutorials
----------------------
* [Install](tutorial/install/)
* [Containers](tutorial/containers/)
* [Quick overview!](tutorial/getting_started/)
* [Introduction](tutorial/introduction/)
* [Background](tutorial/background/)
* [Command-line](tutorial/commandline/)
* [TSV](tutorial/TSV/)
* [TSV#traversal (map-reduce)](tutorial/map_reduce/)
* [Resource](tutorial/Resource/)
* [Workflow](tutorial/Workflow/)
* [HPC (SLURM & LSF)](tutorial/HPC/)
* [Knowledge Base](tutorial/knowledge_base/)

What is up?
-----------

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
