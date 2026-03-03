---
title: TSV (streaming tables)
layout: default
parent: Reference
nav_order: 4
---

Rbbt uses TSV (tab-separated value) files as a *first-class* data format.

The tooling focuses on:

- **large files** (millions of rows)
- **streaming** (don’t load everything into memory)
- **semantics** (columns and “value types” are meaningful)
- **indexing / persistence** (fast random access)

## TSV “types” (value shapes)

Historically, Rbbt classifies TSVs by the shape of the value column(s):

- **single**: one value per key
- **list**: list of values per key
- **double**: list-of-lists per key (multiple columns, each a list)
- **flat**: list of values representing the same aspect (e.g. transcripts)

## When to use it

- Interchange format between tasks
- Cached artifacts (fast to inspect, easy to diff)
- Lightweight data tables for workflows

## Deeper docs

- Legacy deep dive: [TSV tutorial]({{ site.baseurl }}/tutorial/TSV/)
- TSV traversal / map-reduce: [Legacy map-reduce tutorial]({{ site.baseurl }}/tutorial/map_reduce/)
