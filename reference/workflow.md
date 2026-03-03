---
title: Workflow model
layout: default
parent: Reference
nav_order: 2
---

Rbbt’s execution engine is a **workflow system** (implemented in the Scout packages).

At a high level:

- A **workflow** is a named collection of **tasks**.
- A **task** declares:
  - inputs (names, types, defaults)
  - output type
  - dependencies on other tasks
  - how to compute a result
- A task run is a **step/job** with a specific set of inputs.

## Why it matters: caching + provenance

Rbbt/Scout workflows are designed for **reproducibility** and **incrementality**:

- Steps are cached on disk.
- If you run the same task with the same inputs, it can reuse results.
- Metadata/provenance is stored alongside results (inputs used, runtime, dependency graph, etc.).

This is the reason Rbbt can:

- resume interrupted runs
- avoid recomputing expensive intermediate results
- run locally or delegate to remote servers

## Remote execution

Many workflows can be exposed over HTTP and executed remotely.

From the CLI, you can point at a workflow URL:

```bash
rbbt workflow task https://rbbt.bsc.es/Sequence -h
rbbt workflow task https://rbbt.bsc.es/Translation tsv_translate -g TP53,MDM2,RB1
```

## Python task implementations (PythonWorkflow)

In modern Scout-based installs, a workflow may keep the orchestration in Ruby but implement the actual task logic in Python.

See:
- [Write workflows in Python (PythonWorkflow)]({{ site.baseurl }}/start-here/pythonworkflow/)

## Deeper docs

- Legacy deep dive: [Workflow tutorial]({{ site.baseurl }}/tutorial/Workflow/)
- Background: [Why workflows (protocol analogy)]({{ site.baseurl }}/tutorial/background/)
