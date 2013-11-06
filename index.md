---
title: Rbbt
layout: default
tagline: Ruby bioinformatics toolbox
---


What is Rbbt?
-------------

Rbbt stands for "Ruby Bioinformatics Tool-box". It is a framework for software
developement in bioinformatics. It covers three aspects:

* Developing functionalities
* Making the as widely accessible as possible
* Integrating them with one another

Where has Rbbt been used?
-------------------------

Rbbt has been used to power several applications, either in their entirety of
parts of it, like the workflow management:

* [SENT](http://sent.dacya.ucm.es/): semantic features in text
* [BioNMF](http://bionmf.dacya.ucm.es/): Non-negative matrix factorization in biology
* [MARQ](http://marq.dacya.ucm.es/): microarray-rank query
* [Genecodis](http://genecodis.cnb.csic.es/): Gene annotation co-ocurrence discovery
* [3DEM Loupe](http://3demloupe.cnb.csic.es): Normal mode analysis of dynamics of structures from electron microscopy
* [TaLasso](http://talasso.cnb.csic.es/): Quantification of miRNA-mRNA interactions
* [KinMut](http://wkinmut.bioinfo.cnio.es/): Pathogenicity predictions of kinase mutations

These applications have driven the development of the framework over the
years, the code used in them has been re-factored several times since

Where is it used now?
---------------------

Our current interest is in cancer genome analysis. Development in this area has
stimulated the development of several new concepts, such as the Entity
subsystem, a novel concept developed to aleviate the complex challenges of
integration.

The StudyExplorer is our current flagship application. I can be adapted to different
scenarios and several instances of it serves different groups in our institution. An
example deployment is [ICGC Scout](http://se.bioinfo.cnio.es), that provides access to 
all cancer studies from ICGC and TCGA and offers a wide array of functionalities.
*NOTE: The software is not easy to use, it requires training or documentation, which is mostly lacking*

What is in it?
--------------

Well, a large number of workflows have been developed:

* [Sequence](https://github.com/Rbbt-Workflows/sequence): functionalities regarding genomic analysis, such as mutation consequence analysis
* [MutEval](https://github.com/Rbbt-Workflows/mut_eval): evaluation of pathogenicity of variants (it actually interfaces with other systems)
* [Structure](https://github.com/Rbbt-Workflows/structure): functionalities for structural analysis of proteins
* [Enrichment](https://github.com/Rbbt-Workflows/enrichment): over-representation and rank-based methods for enrichment analysis, supporting: Kegg, GO, Nature Curated Cancer Pathways, Reactome, Biocarta, PFAM, Transfac, ect
* and many [more](https://github.com/Rbbt-Workflows)



How can I benefit?
------------------

As a user by using the applications that it powers :) As a developer, by taking
its code apart, copying the ideas, stealing shamelessly the implementations,
or even by using the framework as it is supposed to be used. 

Examples and tutorials
----------------------
* [Introduction](/tutorial/introduction)
* [Install](/tutorial/install)
* [TSV](/tutorial/TSV)
* [Resource](/tutorial/Resource)
* [Workflow](/tutorial/Workflow)
* [Knowledge Base](/tutorial/knowledge_base)

What is up?
-----------

No posts yet.

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>