---
title: CLI overview (rbbt vs scout)
layout: default
parent: Reference
nav_order: 1
---

You may see more than one command name in the ecosystem:

- **`rbbt`** — the classic user-facing CLI used in most Rbbt deployments.
- **`scout-ai`** — the CLI for the Scout-AI package (LLM endpoints, chat files, agents, tool calling).
- **`scout`** — sometimes used in Scout-only (framework-only) installs.

This site generally uses **`rbbt`** for workflow usage examples, and calls out **`scout-ai`** explicitly for AI features.

## Common `rbbt` commands

### Explore workflows

```bash
rbbt workflow list
rbbt workflow task Translation -h
rbbt workflow task Translation translate -h
```

### Run workflow tasks

```bash
# local workflow (installed)
rbbt workflow task Translation translate --genes TP53 --format "Ensembl Gene ID"
```

### Run against a remote workflow server

```bash
rbbt workflow task https://rbbt.bsc.es/Translation translate --genes TP53 --format "Ensembl Gene ID"
```

Tip: remote execution is often the fastest way to try Rbbt without downloading large resources.

## Common `scout-ai` commands

### Ask a model (stateless)

```bash
scout-ai llm ask -e nano "Say hi"
```

### Ask using a chat file (imports + tools + file inclusion)

```bash
scout-ai llm ask -c my.chat -e nano
```

### Agent mode (stateful; automatically exports tools)

```bash
scout-ai agent ask Baking "Bake muffins using the tool"
```

## Related pages

- [Quickstart (remote run)]({{ site.baseurl }}/start-here/quickstart/)
- [Use workflows as tools for LLM agents]({{ site.baseurl }}/start-here/agent-tools/)
- [Rbbt & Scout (project structure)]({{ site.baseurl }}/ecosystem/rbbt-and-scout/)
