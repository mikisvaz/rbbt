---
title: Chat files and roles (Scout-AI)
layout: default
parent: AI
nav_order: 1
---

Scout-AI supports a *chat file* format that is more reproducible than ad-hoc prompting.

A chat file is compiled before inference and can include:

- normal chat turns (`user:`, `assistant:`)
- imports / continuation
- file/directory inclusion
- tool declarations
- tool execution (workflow tasks, KB queries, MCP tools)

## Minimal example

```text
user:

Introduce yourself.
```

## Exposing workflow tasks as tools

```text
user:

introduce: Baking
tool: Baking

Bake muffins using the workflow tools.
```

Then run:

```bash
scout-ai llm ask -c baking.chat -e nano
```

## Where to find the full role reference

The canonical reference currently lives in the Scout-AI package docs.

This documentation site keeps a lightweight overview and focuses on how to apply it in Rbbt contexts.
