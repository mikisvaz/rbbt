---
title: Install & setup
layout: default
parent: Start here
nav_order: 2
---

This page outlines the *recommended* install paths in 2026.

If you only want to **run remote workflows**, you can often skip most of this and start at:
- [Quickstart]({{ site.baseurl }}/start-here/quickstart/)


## Option A (recommended for most users): container image

If your environment has **Singularity** or **Apptainer**, the container image is the lowest-friction way to get a working CLI.

```bash
wget "{{ site.singularity_image_url }}" -O ~/rbbt.singularity.img

# Singularity
alias rbbt='singularity exec -e ~/rbbt.singularity.img rbbt'

# Apptainer (alternative)
# alias rbbt='apptainer exec -e ~/rbbt.singularity.img rbbt'

rbbt --help
```

When using the container, Rbbt will still create state under your home directory (cache, resources, etc.).


## Option B: developer install (Ruby gems)

If you plan to **author workflows**, contribute to the framework, or need a fully local setup, you’ll likely want a Ruby-based install.

High-level steps:

1. Install a Ruby version compatible with your Rbbt/Scout deployment.
2. Install the required gems.
3. Configure paths (resources, cache, workflows).

This repo currently contains the historical installation tutorial:
- [Legacy install tutorial]({{ site.baseurl }}/tutorial/install/)

(As the docs are modernized, this page will be expanded with more explicit “developer” vs “user” setup guidance.)


## Option C: Docker / VM provisioning

Rbbt has tooling to help with provisioning images/VMs in some deployments.

See:
- [Legacy containers tutorial]({{ site.baseurl }}/tutorial/containers/)


## Common setup concepts (regardless of install)

### Bootstrapping
The first time you run a workflow task, it may need to **download/build indices** or **install third-party tools**. This can take time.

### Caching / persistence
Rbbt/Scout heavily relies on caching so results are reproducible and incremental. You will typically see job directories (“steps”) created under your working directory or a configured cache dir.


## Next

- [Write workflow logic in Python (PythonWorkflow)]({{ site.baseurl }}/start-here/pythonworkflow/)
