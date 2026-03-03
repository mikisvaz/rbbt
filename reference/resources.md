---
title: Resources (bootstrapping)
layout: default
parent: Reference
nav_order: 3
---

Many bioinformatics (and scientific computing) tasks depend on:

- reference datasets
- indices
- third-party tools
- derived “prepared” files (normalized, merged, annotated)

Rbbt provides a **Resource** system that manages this *bootstrapping* process.

## Key behaviors

### 1) Lazy / on-demand
Resources are typically built the first time you ask for them.

### 2) Cached on disk
Once built, resources are reused across runs.

### 3) Provenance-friendly
Since workflows cache steps, resource locations tend to be stable and re-usable.

## Practical implications

- The **first run can be slow** (downloads and indexing).
- Later runs are much faster.
- Remote workflow execution can avoid local bootstrapping altogether.

## Related pages

- Quickstart (remote execution): [Start here → Quickstart]({{ site.baseurl }}/start-here/quickstart/)
- Legacy deep dive: [Resource tutorial]({{ site.baseurl }}/tutorial/Resource/)
