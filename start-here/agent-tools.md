---
title: Use workflows as tools for LLM agents
layout: default
parent: Start here
nav_order: 4
---

Rbbt’s workflow engine (Scout Workflow) can be exposed to LLMs as **callable tools**.

In the Scout ecosystem, this is provided by **Scout-AI**:

- `LLM.ask` / `LLM::Agent` for stateful conversations
- a chat-file format with special roles like `tool:` and `mcp:`
- automatic execution of tool calls (workflows / knowledge bases / MCP servers)

This page is intentionally practical: a minimal working pattern you can copy.


## Prerequisites

You need an environment with **Scout-AI** available (CLI: `scout-ai`).

If you are using a full Rbbt distribution that bundles Scout-AI, the commands below should work. Otherwise, install/configure Scout-AI separately.


## Pattern A: expose a workflow as tools in a chat file

Create a file `baking.chat`:

```text
user:

# (optional but recommended) inject workflow docs so the model knows what tools do
introduce: Baking

# expose all tasks of the workflow as callable tools
tool: Baking

Bake muffins using the workflow tools. Prefer calling the tool instead of writing steps.
```

Run it:

```bash
scout-ai llm ask -c baking.chat -e nano
```

What happens:

1. The chat is compiled (imports, tool declarations, file inclusion).
2. The model can call workflow task functions.
3. Tool calls are executed and the trace is appended to the chat.


## Pattern B: agent CLI (workflow-aware)

Scout-AI also provides an agent wrapper that automatically exports workflow tasks as tools:

```bash
scout-ai agent ask Baking "Bake muffins using the tool"
```


## MCP integration (optional)

If you already have tools exposed via an MCP server, chat files can load them too:

```text
mcp: http://localhost:8765
```

Or using an MCP stdio server:

```text
mcp: stdio 'npx -y @modelcontextprotocol/server-filesystem ${pwd}'
```

You can combine MCP tools and workflow tools in the same chat.


## Where to read the full reference

- Scout-AI chat roles (`tool`, `introduce`, `task`, `mcp`, …)
- How tool calling is executed and how endpoints/models are configured

See:

- In this site:
  - [AI → Chat files and roles]({{ site.baseurl }}/ai/chat-files/)
  - [AI → MCP integration]({{ site.baseurl }}/ai/mcp/)
  - [CLI overview (rbbt vs scout)]({{ site.baseurl }}/reference/cli/)
- `scout-ai` package docs: Chat + Agent + LLM (canonical reference)
- [Rbbt & Scout: project structure]({{ site.baseurl }}/ecosystem/rbbt-and-scout/)
