---
title: Genomics pipelines at Marenostrum (BSC)
layout: default
tagline: Stream API
---

# Setting up

* Get assigned to group bsc26
* Load `/gpfs/projects/bsc26/setup_rbbt.sh`, consider adding this to the `.bashrc` file
* Try it out `rbbt`. You should see the command help message

# Rbbt basics

The `rbbt` command is the gateway to using all Rbbt functionalities. It is a
command with one or more sub-commands. Type `rbbt` to see the list of
sub-commands at the end. The ones in white (e.g. migrate) are final commands,
the ones in blue (e.g. workflow) have further sub-commands. Type `rbbt
workflow` to see the `workflow` sub-commands; we will be using one of them to
execute workflow tasks: `rbbt workflow task`.

There should be a number of workflows already available for you, type `rbbt
workflow list` to see them. One of them should be the `HTS` workflow (High
throughput sequencing). This workflow allows you to perform analyses for DNA
and RNA-Seq like alignment and variant calling. To see the tasks available for
the `HTS` workflow type `rbbt workflow task HTS`. To learn how to use any of
these tasks, such as the `mutect2` task, type `rbbt workflow task HTS mutect2
--help`. You can see from the output of the last command that the `mutect2`
task is actually a workflow in itself that builds upon several other tasks. In
particular it has a task performing the actual calling with GATK's Mutect2, and
others that are used to filter out artifacts and low quality variants.
Different steps of the workflow consume different inputs, which may use default
values if omitted. 

# A tiny synthetic example

Gather the [file
bundle](https://b2drop.bsc.es/index.php/s/agcZRzALrYwzND7/download) and unpack
it on a work directory. This is a synthetic sample generated using the [NEAT
genReads tool](https://github.com/zstephens/neat-genreads) You should see
several directories containing the FASTQ files, aligned BAMs and golden BAMs.
Golden BAMs have reads aligned to exactly the place they where simulated from,
while the aligned BAMs are the result of running the standard alignment
pipelines with BWA following the GATK best practices.

## Test the HTS workflow on synthetic data

We can use the synthetic sample to start learning about using the HTS workflow.
Let's begin trying to do `mutect2` variant calling. Type `rbbt workflow task
HTS mutect2 -h` to examine the input options, in particular: `tumor`, `normal`,
and `reference`. To try it out point `tumor` and `normal` to the corresponding
BAM files from the synthetic sample, and specify `hg38` as the `reference`.
Before you actually run it let us first examine the work that Rbbt intends to
do, add the flag `--provenance` to see the dependency tree. Each line in the
provenance tree is indented to reflect the dependency structure, and has four
components: status of the step, workflow, task name, and step path. Initially
they should all be in the status `notfound`. Now we can remove the
`--provenance` flag and actually run the workflow. 

Let it run for a while, like a couple of minutes, and interrupt it with
`<ctrl>-C`. Now display the provenance again and take a look at what was
completed and what remains. Now run the workflow again and watch it resume from
the last completed step. This time however, try adding the flag `--log 0` to
increase the log level and show `DEBUG` info, which includes the output from
the different command-line tools. To make `0` the default log level type `rbbt
log 0`; the default is to show `INFO` level logs, which corresponds to level
`4`.

## Examining the result and the meta-data

Once the workflow is complete the resulting VCF would have appeared in
`STDOUT`; the logs go to `STDERR` so they will not interfere with the output
and you can safely pipe it. The `-pf` flag, which is the short form for
`--printpath`, will show the path to the result file instead of the content.
Lets get it to examine the meta-data (note that we could also get it from the
top of the provenance tree). Notice how alongside the result file is a `.info`
file[^serializer_footnote]. This file contains meta-data that describe the
provenance of the result, the inputs used, time spent, versions of tools used,
etc. Try it out by typing `rbbt workflow info <path>`, which shows just basic
information, including input options specific to that job. The flags `--all`
shows extended information, and the flag `--recursive` traverses the
dependencies to collect all the inputs used across. To examine the provenance tree
from a job result file, instead of at the moment of running the workflow, you can do
`rbbt workflow prov <path>`. 

[^serializer_footnote]:For reasons of performance the file is in a serialized form particular to Ruby, although Rbbt can be instructed to make them YAML by specifying the environment variable `RBBT_INFO_SERIALIZER=YAML`, but it's not recommended. 

One of the benefits of synthetic samples is that we have a truth set to
validate that our pipelines are working correctly. Use the task `compare_vcf`
to compare your variant calling with the truth set used by NEAT `rbbt workflow
task HTS compare_vcf --vcf_1 <your file path> --vcf_2 <path to
truth/somatic.vcf>`. It's should show a large number of `common` variants; it's
OK that they are `common but different`, this only means that the additional
information of the variants, like variant allele frequency, is different, which
is in fact entirely missing on the truth VCF file.

One can also see the status of running jobs, lock files, indices being created,
and other things using the command `rbbt system status HTS --all`, where
workflow `HTS` can be substituted by any other workflow, or the word `all` to
report all workflows; the flag `--all` indicates that all jobs must be shown,
instead of only failed ones. To cleanup do `rbbt system clean HTS`, running
jobs will not be erased or interfered with, except on an HPC environment where
jobs might be executing on a different node and might seem aborted to the
login-node.

## Input options, hashes, redoing work, and configuration keys

I hope by now you have noticed one thing: that Rbbt does not place result files
for a workflow execution isolated from other workflow executions, they all
ended up under `~/.rbbt/var/jobs/`. The idea is that workflow executions
are treated as deterministic given the inputs, so the same workflow issued with
the same inputs can reuse the same results. A few precautions are set in place
to avoid mishaps, the path associated to a step is determined by digesting the
values of the inputs, so different inputs receive a different hash[^input_name_footnote]

[^input_name_footnote]: Rbbt can be instructed to not digest the inputs but list them as-is in the path by setting the environment variable `RBBT_INPUT_JOBNAME=true`, but this is also not recommended.

In order to force that part of the work is redone you must first clean it up.
You can use the flag `--clean` to clean just the task you are calling, leaving
the dependencies as they where, or the flag `--recursive_clean` to clean all
the dependencies and redo the entire job. Alternatively you can also use the
flag `--clean_task` to clean specific dependencies and force that the process
is updated from there on.

If a dependency is updated the downstream steps become not up-to-date, and will
show. To avoid unnecessary computation this does not trigger the need to redo
the downstream steps unless the flag `--update` is used when running the
workflow. Try running the `mutect2_pre` task, which is the one where Mutect2
actually does the variant calling, and then the `mutect2` task with and without
the `--update` flag. Then try running the `mutect2` task with `--clean_task
mutect2_pre`. But before you do so, read the next paragraph!

Rbbt makes a distinction between inputs options that dictate what the result
is, and performance options that dictate how the results is computed. Input
options get digested into the path hash and lead to different provenance trees,
performance options don't alter the dependency tree and are actually specified
through something called `config_keys`. For example, Mutect2 has no internal
support for concurrency, however it can be implemented by dividing the work in
different genomic intervals, an approached often called sharding. To activate
sharding we can specify the following flag `--config_keys 'shard true
mutect2,cpus 10 mutect2'`. This is interpreted as follows, the configuration
key `shard` should be set to true when queried with the key `mutect2` and the
key `cpus` set to `10` when queried also by the key `mutect2`. If you turn the
log level to 0 and scrutinize the output you will see the logs for when these
keys are retrieved. Try running this command 
`rbbt workflow task HTS mutect2 -n <path to normal BAM> -t <path to tumor BAM> -r hg38 --clean_task mutect2_pre
-pf --config_keys 'shard true mutect2,cpus 10 mutect2`. It's a very small
sample but it should show some difference. Checkout the meta-data for the
`mutect2_pre` step to check that the keys show up. Configuration keys can be
placed in particular locations so that one does not have to write them all the
time, but we will see that later.

# Using the Sample workflow

When running the `mutect2` task you didn't need to specify where reference data
and their indices where; Rbbt found them for you. A similar thing can be done
for the input data, once they are properly organized Rbbt can find them for
you. This is done with the Sample workflow, that puts together a portfolio of
different queries that can be asked about patients and figures out the right
workflow to answer them. In the group 'bsc26' there are a few test samples
already organized for you. Let us check those out first and them we will see
how to setup the synthetic example to work the same way

Let start by checking what are the test samples we have available. Type the
`studies` command from the `HTS` workflow to see available studies. You should
find the example studies that you can use to test the pipelines. `rbbt workflow
cmd HTS studies`

You should see several test samples, like `NA12878`, which is a germline WGS
sample often used in benchmarks. This is not a good sample to test, because
it's very large. A better option 

