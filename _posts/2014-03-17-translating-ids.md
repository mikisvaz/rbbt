---
title: Translating IDs
layout: default
tagline: Translating IDs
---

# Translating IDs

This post will show how to use the Rbbt workflow `Translation` to translate
between identifier formats.  You will need a working ruby installation, and the
gems `rbbt-util`, `rbbt-rest` and `rbbt-sources`.

## Prepare infrastructure

Install the translation workflow doing `rbbt workflow install Translation`.
Bootstrap the installation issuing `rbbt workflow cmd Translation bootstrap`.
That will prepare the system for identifier translation of *H*omo *sa*piens
(*Hsa*) for the builds of may2009 (hg18) and jun2011 (hg19) and the most recent
build. The default organism used is *Hsa*, which stands for the most recent
build of *H. sapiens*.

To avoid building all the resources from scratch, before the bootstrap use
the following command
`rbbt file_server add Organism http://se.bioinfo.cnio.es`. This will download
precompiled resources from the server. Incices and caches will still need to be
prepared.

Alternatively, setup a remote Translation workflow by doing 
`rbbt workflow remote add Translation http://se.bioinfo.cnio.es/Translation`

## Use

You can now translate a list of gene ids as follows:

```bash
rbbt workflow task Translation translate --format "Ensembl Gene ID" --genes "TP53|MDM2"
```
or, using the following command, which retains the correspondance between ids:

```bash
rbbt workflow task Translation tsv_translate --format "Ensembl Gene ID" --genes "TP53|MDM2"
```

You may change the format to any of the formats in the corresponding identifier
file:

```bash
rbbt tsv info ~/.rbbt/share/organisms/Hsa/identifiers
```

For simplicity you may also use:

```bash
rbbt workflow task Translation formats 
```

The most common are:
 
  * Ensembl Gene ID
  * Associated Gene Name
  * UniProt SwissProt Accession

*Note that CASE is ALWAYS IMPORTANT*

You may use the organism codes 'Hsa', 'Hsa/may2009' and 'Hsa/jun2011'. Other
organisms are supported: 'Mmu' and 'Sce'. Any Ensembl archive date can be
specified, but it will require preparing that infrastructure as well.

