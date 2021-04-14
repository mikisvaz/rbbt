---
title: HPC (SLURM & LSF)
layout: default
tagline: Submission to batch systems
---
# Submission to batch systems

## Introduction

The command `rbbt workflow task` is the basic way to run workflow tasks in
Rbbt. It starts executing the workflow steps in order, following the dependency
tree, to build up the result. If you have access to a HPC resource you can make
use of this approach by allocating enough resources for your job and running
this command.

Executing commands with `rbbt workflow task` enacts the entire workflow
controlled from a single process, which means that it can make use of some of
the advanced features in Rbbt, like streaming outputs across workflow steps.
However, this approach has an important problem, which is that for
heterogeneous workloads the allocation made might not necessarily reflect the
actual needs of the different steps. In other words, one must allocate enough
resources for the most expensive steps, which might mean that when computing
steps that do not require so many resources these might end up underused. 

For illustration consider a standard genome alignment workflow such as this one
defined in the `HTS` workflow:

<pre>
HTS#BAM
 HTS#BAM_rescore
  HTS#BAM_sorted
   HTS#BAM_duplicates
    HTS#BAM_bwa
     HTS#uBAM
     HTS#mark_adapters
</pre>

The `mark_adapters` and `uBAM` steps are single-threaded, while the `BAM_bwa`
and `BAM_rescore` can make use of multiple CPUs. Clearly reserving multiple
CPUs for this workflow will start by underusing the resources during the
initial steps.

## Orchestration by dependency blocks

To allow more flexibility Rbbt can easily break down the execution on a
particular workflow by asking the execution of intermediate dependencies in any
particular way, which allows the use of other orchestration devices to replace
the native approach. In fact, a hybrid approach can be used so that the
dependency tree can be split into blocks of dependencies, each executing their
internal steps using by the native scheduler, but using some other
orchestration device for each block.

In our alignment workflow for instance we can define one single-threaded block
doing the first two steps of `mark_adapters` and `uBAM`, another block doing
`BAM_bwa` with multiple CPUs, other single-threaded one doing `BAM_duplicates`
and a final multi-threaded one for the final steps for sorting and re-scoring.

To help with this process, Rbbt provides a set of functionalities that help
deploy these blocks in SLURM and LSF. 

## The HPC subsystem

Rbbt supports SLURM and LSF almost identically through the commands under `rbbt
slurm` and `rbbt lsf`, which have identical sub-commands. In fact, they are
exactly the same, and calling them through one or the other serves only to
indicate rbbt which tools to use. The `rbbt hpc` is exactly like the other two
but attempts to auto-detect the batch system to use. We will use `rbbt hpc` 
here for illustration.

### HPC Task

The `rbbt hpc task` command is just like `rbbt workflow task` but with a few
new option flags that can control the characteristics of the allocation: CPUs,
time, queue, etc. It still does no orchestration, but it is still very useful
and  important to understand. It works almost exactly as the `rbbt workflow
task` version, except that if it needs to execute something it sends it to the
batch system instead of running it directly. If the workflow that is required
is already computed the result will be presented as usual, and other things
like examining provenance or consulting documentation also work exactly the
same.

When `rbbt hpc task` does need to execute a job it creates a script that it
submits to the batch system, this script prepares a few things and calls `rbbt
workflow task`. To organize this process for you, each submission is associated
with its own directory under `~/rbbt-batch/`, which contains the command
script, a file with the job id, and, as the job gets started and completed
several other files appear. The files are the following:

* `command.batch`: Script submitted to the batch system calling `rbbt workflow task`
* `job.id`: Job id in the batch system
* `dependencies.list`: List of other job ids that need to be completed successfully before starting this one (see HPC Orchestrate)
* `canfail_dependencies.list`: List of other job ids that need to be completed before starting this one but are allowed to fail (see HPC Orchestrate)
* `inputs_dir`: Inputs for the `rbbt workflow task` called inside `command.batch`, they are equivalent to the ones specified in `rbbt hpc task` but are compatible with using contained and hardened environments (see below)
* `std.err`: STDERR of `command.batch`
* `std.out`: STDOUT of `command.batch`, which should only be from `rbbt workflow task`
* `env.vars`: Environment variables before calling `rbbt workflow task`
* `exit.status`: Exit status of the `rbbt workflow task` command
* `procpath.sqlite3`: Procpath metrics (if procpath is used)
* `procpath.cpu.svg`: Procpath CPU usage plot (if procpath is used)
* `procpath.rss.svg`: Procpath Memory usage plot (if procpath is used)
* `sync.log`: When work is done in contained or hardened environments (see below), log of synchronization of results
* `sync.status`: Exit status of sync process

You can prepare the submission script but avoid submitting it to the batch
system by using the flag `--dry_run`, which will also print the script for your
inspection.

The command `rbbt hpc list` examines the content of `~/rbbt-batch` to display
the jobs that have been issued and their status: done, queue, running, error,
or aborted. This command can also be used to display the parameters specified
to the batch system (CPUs, time, queue, etc), the last few lines of the STDERR,
progress of current task, procpath metrics, etc. 

The command `rbbt hpc clean` can be used to clean up directories in
`~/rbbt-batch`. By default it clean only `error` and `aborted` submissions. To
monitor the progress of a particular submission you can use `rbbt hpc tail`,
which will wait until the submission starts executing and then will tail its
STDERR. You can also use the `--tail` directly in `rbbt hpc task` to
immediately start tailing a new submission.

### HPC Orchestrate

The command `rbbt hpc orchestrate` is similar to `rbbt hpc task` but uses an
additional option called `--orchestration_rules` which specify how the workflow
will be broken down into blocks and deployed into the batch system. The rules
are specified in a YAML file and are processed by `rbbt hpc orchestrate` to
build the different submissions. All blocks will be immediately submitted,
using the features provided by SLURM and LSF to stablish dependencies between
jobs to ensure that their execution is done in order and that if one job fails
other jobs depending on it been completed successfully are abandoned. The
`--orchestation_rules` file also specifies batch system parameters like CPUs
and time, as well as `config_keys` specific for each task. 

Consider the following `--orchestration_rules` file:

<pre>
---
defaults:
 time: 10h
 log: 0
 config_keys: >-
   spark false GATK, 
   forget_dep_tasks true forget_dep_tasks, 
   remove_dep_tasks recursive remove_dep_tasks, 
   remove_dep false HTS#mutect2_filters, 
   remove_dep false HTS#BAM_sorted
HTS:
 BAM_rescore:
  task_cpus: 20
  config_keys: >- 
    shard true rescore,
    cpus 8 rescore, 
    cpus 20 sort, 
    samtools_sort true bam_sort, 
    threads 15 samtools_sort_threads, 
    max_mem 2G samtools_sort_max_mem
 BAM_sorted:
  task_cpus: 4
  config_keys: >-
    samtools_sort true bam_sort, 
    threads 4 samtools_sort_threads, 
    max_mem 3G samtools_sort_max_mem
 BAM_orientation_model:
  task_cpus: 4
 BAM_duplicates:
  task_cpus: 20
 BAM_multiplex:
  task_cpus: 20
 BAM_bwa:
  task_cpus: 20
  config_keys: cpus 18 bwa
 mutect2_pre:
  task_cpus: 20
  config_keys: shard true mutect2, cpus 8 mutect2
 haplotype:
  task_cpus: 20
  config_keys: shard true haplotype, cpus 10 haplotype
 strelka_pre:
  task_cpus: 20
  config_keys: cpus 20 strelka
 muse:
  task_cpus: 20
  config_keys: cpus 20 muse
 svABA:
  config_keys: cpus 20 svABA
Sample:
 defaults:
  task_cpus: 1
  skip: true
chains:
 pre_align:
  workflow: HTS
  tasks: uBAM, mark_adapters
  task_cpus: 1
 post_mutect2:
  workflow: HTS
  tasks: mutect2_filtered, mutect2_clean, mutect2
  task_cpus: 4
 post_strelka:
  workflow: HTS
  tasks: >-
    HTS#strelka_pre_indels, 
    HTS#strelka_filtered_indels, 
    HTS#strelka_filtered, 
    HTS#strelka
  task_cpus: 2
</pre>

This file defines first a set of default values: 2 hours for each job, log
level 0 (`DEBUG`) and some `config_keys` that deactivate spark for all GATK
functions, and indicate that `dependency_tasks`[^footnote_dep_task] must be
forgotten and recursively erased except for `mutect2_filters` and `BAM_sorted`,
which I'm interested to keep around for debug purposes.

The next section override and extend the defaults for particular tasks from the
`HTS` workflow. For the `Sample` workflow tasks are generally
`dependency_tasks` and are immediate, so they are assigned `skip: true`, which
instructs the orchestrator to avoid making a submission with them alone, and
always try to piggyback them on another submission. The final section indicates
some explicit bundles of tasks that should be joined into the same submissions
since they require similar allocations. Joining different steps into the same
submission is used mainly to reduce the number of submissions made and the time
spent queuing, but it could also allow some of the advanced streaming features
across workflow tasks; although currently streaming features are not used on
the `HTS` pipelines.

To see what the bundled look like you can use the `--dry_run` flag. When used
with the `rbbt hpc orchestrate` command it will list the submission bundles.
For instance for the ARGO-NEAT using the previous YAML file `rbbt hpc
orchestrate Sample -W HTS mutect2 -jn ARGO-NEAT --dry_run --orchestration_rules
~/.rbbt/etc/slurm/varcalling.yaml` it shows the following submissions

<pre>
Manifest: HTS#mark_adapters, HTS#uBAM - tasks: 1 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps:
Manifest: HTS#BAM_bwa - tasks: 20 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted,cpus 18 bwa
Deps: HTS#mark_adapters
Manifest: HTS#BAM_duplicates - tasks: 20 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: HTS#BAM_bwa
Manifest: HTS#BAM_sorted - tasks: 4 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted,samtools_sort true bam_sort,threads 4 samtools_sort_threads,max_mem 3G samtools_sort_max_mem
Deps: HTS#BAM_duplicates
Manifest: Sample#BAM_normal, Sample#BAM, HTS#BAM, HTS#BAM_rescore - tasks: 20 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted,shard true rescore,cpus 8 rescore,cpus 20 sort,samtools_sort true bam_sort,threads 15 samtools_sort_threads,max_mem 2G samtools_sort_max_mem
Deps: HTS#BAM_sorted
Manifest: HTS#mark_adapters, HTS#uBAM - tasks: 1 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps:
Manifest: HTS#BAM_bwa - tasks: 20 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted,cpus 18 bwa
Deps: HTS#mark_adapters
Manifest: HTS#BAM_duplicates - tasks: 20 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: HTS#BAM_bwa
Manifest: HTS#BAM_sorted - tasks: 4 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted,samtools_sort true bam_sort,threads 4 samtools_sort_threads,max_mem 3G samtools_sort_max_mem
Deps: HTS#BAM_duplicates
Manifest: Sample#BAM, HTS#BAM, HTS#BAM_rescore - tasks: 20 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted,shard true rescore,cpus 8 rescore,cpus 20 sort,samtools_sort true bam_sort,threads 15 samtools_sort_threads,max_mem 2G samtools_sort_max_mem
Deps: HTS#BAM_sorted
Manifest: HTS#BAM_pileup_sumaries - tasks: 1 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: Sample#BAM
Manifest: HTS#BAM_pileup_sumaries - tasks: 1 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: Sample#BAM_normal
Manifest: HTS#contamination - tasks: 1 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: HTS#BAM_pileup_sumaries, Sample#BAM, Sample#BAM_normal
Manifest: HTS#mutect2_pre - tasks: 20 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted,shard true mutect2,cpus 8 mutect2
Deps: Sample#BAM, Sample#BAM_normal
Manifest: HTS#BAM_orientation_model - tasks: 4 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: HTS#mutect2_pre
Manifest: HTS#mutect2_filters - tasks: 1 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: canfail:HTS#contamination, HTS#BAM_orientation_model, HTS#mutect2_pre, Sample#BAM, Sample#BAM_normal
Manifest: Sample#mutect2, HTS#mutect2, HTS#mutect2_clean - tasks: 4 - time: 48h - config: spark false GATK,forget_dep_tasks true forget_dep_tasks,remove_dep_tasks recursive remove_dep_tasks,remove_dep false HTS#mutect2_filters,remove_dep false HTS#BAM_sorted
Deps: HTS#mutect2_filters
</pre>

The output is a bit verbose due to the `config_keys`; the output in the
terminal is colored and should be easier to parse by eye. Note however how some
submissions list several tasks in the manifest, and the dependencies
established between them. All the submissions are sent at the same time, and
there is not process monitoring their progress, the batch system itself will
take care of starting a job when the dependencies finish. Note also how some
dependencies have the prefix `canfail:` which indicate that work may continue
even if the dependency fails, this is used for instance for contamination
calculations, which do not make sense for models organisms like mouse.








