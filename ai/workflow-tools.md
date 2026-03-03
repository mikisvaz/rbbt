---
title: Workflows as tools (concepts)
layout: default
parent: AI
nav_order: 3
---

The key idea is: **a workflow task can be presented to an LLM as a callable function**.

This makes it possible to:

- keep “thinking” in the model
- keep “doing” (computation, data fetching, running pipelines) in workflows
- get reproducible, cached outputs as artifacts

## Practical patterns

### 1) Give the model tool affordances

Use `introduce:` so the model gets task docs, then `tool:` to export functions.

### 2) Keep tool output bounded

Scout-AI caps tool outputs to avoid flooding the context window.

### 3) Use workflows for anything expensive or deterministic

If a task is slow, data-heavy, or you want provenance/caching, it belongs in a workflow.

## Start here

- [Tutorial: Use workflows as tools for LLM agents]({{ site.baseurl }}/start-here/agent-tools/)
