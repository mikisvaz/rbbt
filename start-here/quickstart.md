---
title: Quickstart (run a workflow now)
layout: default
parent: Start here
nav_order: 1
---

This quickstart is optimized for: **“I want to run something immediately.”**

There are two common ways to do that:

1) **Call a remote workflow server** (often no local bootstrapping).
2) **Use the container image** to get an `rbbt` CLI with minimal setup.


## 1) Remote execution (minimal / no install)

Many workflows are exposed as remote services.

If you already have an `rbbt` CLI (native install *or* container), you can query help and run tasks by pointing `rbbt workflow task` at the workflow URL.

If you *don’t* have the CLI yet, you can still call the service directly with `wget`/`curl` (examples below).

### Inspect available tasks / get help

```bash
# List tasks / show help
rbbt workflow task https://rbbt.bsc.es/Sequence -h

# Help for a specific task
rbbt workflow task https://rbbt.bsc.es/Sequence -h mutated_isoforms_fast
```

### Run a simple task

```bash
# Example: translate gene symbols
rbbt workflow task https://rbbt.bsc.es/Translation tsv_translate -g TP53,MDM2,RB1
```

### Remote run via plain HTTP (wget/curl) — works without `rbbt`

Remote workflow services accept `GET` or `POST`. Results can be returned as:

- `_format=raw` (plain text)
- `_format=json` (structured)

Example (GET):

```bash
wget "https://rbbt.bsc.es/Sequence/mutated_isoforms?mutations=7:31003700:T&organism=Hsa/feb2014&_format=raw" --quiet -O -
```

Example (POST + file upload):

```bash
curl -H "Expect:" -L https://rbbt.bsc.es/Sequence/mutated_isoforms_fast \
  -F "_format=raw" \
  -F "mutations=@<file>" \
  -F "organism=Hsa/feb2014"
```


## 2) Container quickstart (CLI)

If you want the local `rbbt` CLI without installing Ruby gems, use the published container image:

```bash
wget "{{ site.singularity_image_url }}" -O ~/rbbt.singularity.img
alias rbbt='singularity exec -e ~/rbbt.singularity.img rbbt'

rbbt --help
```

If you’re using **Apptainer**:

```bash
alias rbbt='apptainer exec -e ~/rbbt.singularity.img rbbt'
```


## Next

- [Install & setup]({{ site.baseurl }}/start-here/install/) — container vs developer install, config locations
- [Legacy tutorials]({{ site.baseurl }}/tutorial/) — deeper background on Workflow/TSV/Resources/HPC
