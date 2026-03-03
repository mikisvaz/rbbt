---
title: Rbbt & Scout (project structure)
layout: default
parent: Ecosystem
nav_order: 1
---

Rbbt started as the **Ruby Bioinformatics Toolkit**.

Over time, many parts of “Rbbt core” were refactored into smaller, reusable libraries under the **Scout** umbrella. This makes it easier to:

- reuse the same core primitives in different projects
- keep configuration and prompts reproducible
- expose workflows as tools for agents
- support non-Ruby task implementations (notably Python)

A useful mental model:

- **Rbbt** is the *user-facing framework + bioinformatics workflows ecosystem*.
- **Scout** is the *modern core library split* that powers Rbbt.


## Package map (where things live)

| Area | What you get | Scout package(s) |
|---|---|---|
| Workflow engine | tasks, steps, dependencies, job directories, provenance/persistence | `scout-gear` |
| TSV / data tables | streaming TSV, semantics, indexing, traversal | `scout-gear` |
| Resources | bootstrapping data/software resources | `scout-essentials` |
| CMD / processes | running external tools, logging, streaming IO | `scout-essentials` |
| AI / chat files | endpoints, chat compilation, tool calling, agents | `scout-ai` |
| Python bridge | call Python from Ruby; pandas/TSV helpers; Python workflow client | `scout-rig` |


## Why the split matters for documentation

This documentation site keeps **Rbbt as the front-door** (the stable name many users search for), but increasingly documents features in “Scout terms”:

- because the newest capabilities land in Scout packages first
- because non-bioinformatics users may consume Scout directly

When a page says “Scout”, you can usually read it as “the modern core of Rbbt”.


## How to proceed (practical guidance)

### If you are a workflow *user*
Start with:

- [Quickstart: run a workflow now]({{ site.baseurl }}/start-here/quickstart/)
- [Install & setup]({{ site.baseurl }}/start-here/install/)

### If you are a workflow *developer*
Start with:

- [Write workflows in Python (PythonWorkflow)]({{ site.baseurl }}/start-here/pythonworkflow/)
- Legacy deep dives:
  - [Workflow tutorial]({{ site.baseurl }}/tutorial/Workflow/)
  - [Resource tutorial]({{ site.baseurl }}/tutorial/Resource/)

### If you want the AI-native interface
Start with:

- [Use workflows as tools for LLM agents]({{ site.baseurl }}/start-here/agent-tools/)


## Notes on naming

You may encounter both `rbbt` and `scout` command names in different environments.

- Many deployments keep **`rbbt`** as the canonical CLI.
- Some Scout-only deployments use **`scout`** for framework-only usage.

This documentation tries to:

- use **`rbbt`** in Rbbt user-facing examples
- mention **`scout-ai`** explicitly for the AI tooling

See also:

- [CLI overview (rbbt vs scout)]({{ site.baseurl }}/reference/cli/)
- [AI section]({{ site.baseurl }}/ai/)
