---
title: MCP integration
layout: default
parent: AI
nav_order: 2
---

Scout-AI can load tools from MCP (Model Context Protocol) servers and expose them to the model alongside workflow tools.

## Load an MCP HTTP server

In a chat file:

```text
mcp: http://localhost:8765
```

## Load an MCP stdio server

In a chat file:

```text
mcp: stdio 'npx -y @modelcontextprotocol/server-filesystem ${pwd}'
```

## Combine MCP + workflow tools

```text
user:

mcp: http://localhost:8765
introduce: Baking
tool: Baking

Use workflow tools for computation and MCP tools for filesystem inspection.
```

## Related

- [Tutorial: workflows as tools]({{ site.baseurl }}/start-here/agent-tools/)
