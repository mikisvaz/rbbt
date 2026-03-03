---
title: Rbbt
layout: default
nav_order: 1
description: Reproducible workflows & data framework for bioinformatics (powered by Scout)
---

Rbbt is a **reproducible workflow + data framework for scientific computing and bioinformatics**.

- Run workflows locally *or* against **remote workflow servers**
- Work with large datasets using **streaming TSV** primitives
- Bootstrap software/data via **Resources** (with caching + provenance)
- Build workflows in Ruby, and (in modern Scout-based installs) implement **workflow tasks in Python**
- Integrate with LLM agents: **workflow tasks as tools** (and MCP tool support)


## Pick your path (3 golden paths)

[Run something now (quickstart)]({{ site.baseurl }}/start-here/quickstart/) {: .btn .btn-primary }
[Install & setup]({{ site.baseurl }}/start-here/install/) {: .btn }
[Write workflows in Python]({{ site.baseurl }}/start-here/pythonworkflow/) {: .btn }
[Use workflows as LLM tools]({{ site.baseurl }}/start-here/agent-tools/) {: .btn }

1) **I just want to run something** → start with **remote execution** and a minimal CLI setup:
   - [Quickstart: run a workflow remotely]({{ site.baseurl }}/start-here/quickstart/)

2) **I want to develop workflows, but I don’t want to write Ruby** → write task logic in Python and keep Ruby as orchestration:
   - [Write a workflow task in Python (PythonWorkflow)]({{ site.baseurl }}/start-here/pythonworkflow/)

3) **I want to understand the framework / build an app** → learn the core concepts (Workflow, TSV, Resources, HPC/remote):
   - [Legacy tutorials (concepts & deep dives)]({{ site.baseurl }}/tutorial/)


## In a hurry? (container quickstart)

If you just want a working `rbbt` CLI without a Ruby install, you can use the published container image:

```bash
wget "{{ site.singularity_image_url }}" -O ~/rbbt.singularity.img
alias rbbt='singularity exec -e ~/rbbt.singularity.img rbbt'

# sanity check
rbbt --help
```

(If your system uses **Apptainer**, replace `singularity` with `apptainer`.)


## Rbbt and Scout (what’s the relationship?)

Historically, Rbbt started as the “Ruby Bioinformatics Toolkit”. The modern core has been split into smaller, reusable packages under the **Scout** ecosystem.

If you’re new: you can think of it as:

- **Rbbt = the user-facing framework + ecosystem**
- **Scout = the core libraries that power modern Rbbt**

Details and a repo map:
- [Rbbt & Scout: project structure]({{ site.baseurl }}/ecosystem/rbbt-and-scout/)


## Example: run a workflow task remotely

One easy way to try Rbbt workflows is to use a remote workflow server (no local bootstrapping):

```bash
# list tasks and get help
rbbt workflow task https://rbbt.bsc.es/Sequence -h
rbbt workflow task https://rbbt.bsc.es/Sequence -h mutated_isoforms_fast

# translate gene symbols
rbbt workflow task https://rbbt.bsc.es/Translation tsv_translate -g TP53,MDM2,RB1
```


## What’s in this documentation site?

- **Start here** (new, guided):
  - [Quickstart]({{ site.baseurl }}/start-here/quickstart/)
  - [Install & setup]({{ site.baseurl }}/start-here/install/)
  - [PythonWorkflow]({{ site.baseurl }}/start-here/pythonworkflow/)
  - [LLM tools / agents]({{ site.baseurl }}/start-here/agent-tools/)

- **Reference** (new, concise):
  - [CLI overview]({{ site.baseurl }}/reference/cli/)
  - [Workflow model]({{ site.baseurl }}/reference/workflow/)
  - [Resources]({{ site.baseurl }}/reference/resources/)
  - [TSV]({{ site.baseurl }}/reference/tsv/)

- **AI** (new, Scout-AI overview):
  - [AI section]({{ site.baseurl }}/ai/)

- **Legacy tutorials** (existing content; being reorganized):
  - [Tutorial index]({{ site.baseurl }}/tutorial/)


## Updates / posts

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
