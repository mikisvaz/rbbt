---
title: LLM endpoints (Scout-AI)
layout: default
parent: AI
nav_order: 4
---

Scout-AI uses **named endpoints** so you can refer to a configuration by a short name like `nano` or `deep`.

An endpoint is defined by a YAML file:

```text
~/.scout/etc/AI/<endpoint>
```

Example:

```yaml
# ~/.scout/etc/AI/nano
backend: responses
model: gpt-5-nano
```

Then:

```bash
scout-ai llm ask -e nano "Say hi"
```

## Typical keys

- `backend`: which backend adapter to use (e.g. `responses`, `openai`, `anthropic`, `ollama`, `vllm`, `openwebui`, `bedrock`)
- `model`: backend-specific model id
- `url`: server URL (for backends like `ollama`/`vllm`/`openwebui`)

Many additional keys are passed through to the backend.

## Why this matters for Rbbt integrations

When you use workflows as tools, *reproducibility* improves if:

- the endpoint configuration is named and checked into team conventions
- the chat file is saved (instead of copying prompts around)

## Related

- [Chat files and roles]({{ site.baseurl }}/ai/chat-files/)
- [Workflows as tools]({{ site.baseurl }}/ai/workflow-tools/)
