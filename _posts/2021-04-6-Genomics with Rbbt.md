---
title: Genomics with Rbbt
layout: default
tagline: Stream API
---

# Asciinema

If you would like to see a terminal cast with this same information, please
visit the following casts:

## Rbbt tutorial 1.- HTS workflow basic usage 

[![asciicast](https://asciinema.org/a/410445.svg)](https://asciinema.org/a/410445?speed=2)

## Rbbt tutorial 2.- Sample workflow

[![asciicast](https://asciinema.org/a/410446.svg)](https://asciinema.org/a/410446)

## Rbbt tutorial 3.- downstream analysis

[![asciicast](https://asciinema.org/a/410447.svg)](https://asciinema.org/a/410447)

# Setup

This guide assumes that you have access to a working installation of Rbbt
prepared for genomics analysis. If not, check out the alternative ways to
[setup an Rbbt installation](/rbbt/tutorial/install/). If you decide to use the
singularity image instead of a native installation, consider downloading [this
version]({{ site.singularity_HTS_image_url }}) which has pre-installed most of the
software tools you will need.


# Rbbt basics

The `rbbt` command is the gateway to using all Rbbt functionalities. Chain
together sub-commands to reach the particular functionality you are interested
in. Type `rbbt` to see the list of sub-commands, which is at the end of the
help page. The sub-commands in white (e.g. migrate) are final commands and have
their own documentation, the ones in blue (e.g. workflow) have further
sub-commands. Type `rbbt workflow` to see the `workflow` sub-commands; we will
be using one of them to execute workflow tasks: `rbbt workflow task`.

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
values if omitted. Note that option flags have shorthand forms, for instance
`-h` is equivalent to `--help`; we will be making use of this shorthand forms
arbitrarily throughout these tutorials to shorten commands[^footnote_shorthand].

[^footnote_shorthand]: shorthand forms of flags, in particular for task input options, are often computed from the long form of the inputs of tasks, and any collisions that might happen are automatically resolved in order of appearance. This makes it so that the same input might have different shorthand forms depending on the workflow task being executed. Please consult the help for any workflow task before using the shorthand forms.

# A tiny synthetic example

Gather the [file
bundle](https://b2drop.bsc.es/index.php/s/agcZRzALrYwzND7/download) and unpack
it on a work directory. This is a synthetic sample generated using the [NEAT
genReads tool](https://github.com/zstephens/neat-genreads). You should see
several directories containing the FASTQ files, aligned BAMs and golden BAMs.
Golden BAMs have reads aligned to exactly the place they where simulated from,
while the aligned BAMs are the result of running the standard alignment
pipelines with BWA following the GATK best practices.

## Test the HTS workflow on synthetic data

We can use the synthetic sample to start learning about the HTS workflow. Let's
begin by doing variant calling with Mutect2. Type `rbbt workflow task HTS
mutect2 -h` to examine the input options, in particular: `tumor`, `normal`, and
`reference`. To try it out point `tumor` and `normal` to the corresponding
aligned BAM files from the synthetic sample, not the golden ones[^footnote_not_golden], and specify
`hg38` as the `reference`. Before you actually run it let us first examine the
work that Rbbt intends to do, add the flag `--provenance` to see the dependency
tree. Each line in the provenance tree is indented to reflect the dependency
structure, and has four components: status of the step, workflow, task name,
and step path. Initially they should all be in the status `notfound`. Now we
can remove the `--provenance` flag and actually run the workflow. 

[^footnote_not_golden]: The golden files where generated using a minified version of the reference, to assure that the size of the sample is very small. This unfortunately makes it incompatible with using a regular hg38 reference. To analyze the golden BAM files you would need to point the `reference` and the `known_sites` to their minified versions provided in the file bundle.

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

[^serializer_footnote]:For reasons of performance the `.info` file is in a serialized form particular to Ruby, although Rbbt can be instructed to make them YAML by specifying the environment variable `RBBT_INFO_SERIALIZER=YAML`, but it's not recommended. 

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
different queries that can be asked about samples (i.e. patients), figuring out
the right workflow to answer them. 

## Preparing the synthetic data for the Sample workflow

In order to incorporate a new sample to the `Sample` workflow the data must be
placed somewhere that Rbbt can find, one such place is in the home directory of the user,
under `~/.rbbt/share/data/studies/`. For example, to prepare the synthetic data
we create the folder `~/.rbbt/share/data/studies/ARGO-NEAT`, inside we need to have
the following directory tree:

<pre>
~/.rbbt/share/data/studies/ARGO-NEAT/
├── WGS
│   ├── ARGO-NEAT
│   │   ├── tumor_read1.fq.gz
│   │   └── tumor_read2.fq.gz
│   └── ARGO-NEAT_normal
│       ├── normal_read1.fq.gz
│       └── normal_read2.fq.gz
└── options
    └── reference
</pre>

This creates the `ARGO-NEAT` study, which contains the sample also named
`ARGO-NEAT` along with its matched normal `ARGO-NEAT_normal`. Here we copy or
link the FASTQ files. The `options/reference` contains the text `hg38` to make
sure this is the reference used to analyze this sample, unless otherwise
specified.

It's a matter of preference, but I find that in practice is often practical to
include all the data that was provided as it was provided originally in some
other directory, `data` in this case, and link to it as Rbbt likes it. This way
one can move this directory around easily and never lose track of the original
contents.

<pre>
~/.rbbt/share/data/studies/ARGO-NEAT/
├── WGS
│   ├── ARGO-NEAT
│   │   ├── tumor_read1.fq.gz -> ../../data/FASTQ/tumor/tumor_read1.fq.gz
│   │   └── tumor_read2.fq.gz -> ../../data/FASTQ/tumor/tumor_read2.fq.gz
│   └── ARGO-NEAT_normal
│       ├── normal_read1.fq.gz -> ../../data/FASTQ/normal/normal_read1.fq.gz
│       └── normal_read2.fq.gz -> ../../data/FASTQ/normal/normal_read2.fq.gz
├── data
│   ├── BAM
│   │   ├── normal.bai
│   │   ├── normal.bam
│   │   ├── normal.bam.md5
│   │   ├── tumor.bai
│   │   ├── tumor.bam
│   │   └── tumor.bam.md5
│   ├── FASTQ
│   │   ├── normal
│   │   │   ├── normal_read1.fq.gz
│   │   │   └── normal_read2.fq.gz
│   │   └── tumor
│   │       ├── tumor_read1.fq.gz
│   │       └── tumor_read2.fq.gz
│   ├── golden_BAM
│   │   ├── normal_golden.bam
│   │   ├── normal_golden.bam.bai
│   │   ├── tumor_golden.bam
│   │   └── tumor_golden.bam.bai
│   ├── known_sites
│   │   ├── 1000G_phase1.indels.vcf.gz
│   │   ├── 1000G_phase1.indels.vcf.gz.tbi
│   │   ├── 1000G_phase1.snps.high_confidence.vcf.gz
│   │   ├── 1000G_phase1.snps.high_confidence.vcf.gz.tbi
│   │   ├── Miller_1000G_indels.vcf.gz
│   │   ├── Miller_1000G_indels.vcf.gz.tbi
│   │   ├── af-only-gnomad.vcf.gz
│   │   ├── af-only-gnomad.vcf.gz.tbi
│   │   ├── dbsnp_146.vcf.gz
│   │   ├── dbsnp_146.vcf.gz.tbi
│   │   ├── panel_of_normals.vcf.gz
│   │   ├── panel_of_normals.vcf.gz.tbi
│   │   ├── small_exac_common_3.vcf.gz
│   │   └── small_exac_common_3.vcf.gz.tbi
│   ├── reference
│   │   ├── hg38.dict
│   │   ├── hg38.fa
│   │   ├── hg38.fa.amb
│   │   ├── hg38.fa.ann
│   │   ├── hg38.fa.bwt
│   │   ├── hg38.fa.byNS.interval_list
│   │   ├── hg38.fa.fai
│   │   ├── hg38.fa.gz
│   │   ├── hg38.fa.gz.amb
│   │   ├── hg38.fa.gz.ann
│   │   ├── hg38.fa.gz.bwt
│   │   ├── hg38.fa.gz.byNS.interval_list
│   │   ├── hg38.fa.gz.fai
│   │   ├── hg38.fa.gz.gzi
│   │   ├── hg38.fa.gz.pac
│   │   ├── hg38.fa.gz.sa
│   │   ├── hg38.fa.gzi
│   │   ├── hg38.fa.pac
│   │   └── hg38.fa.sa
│   └── truth
│       ├── germline.vcf
│       ├── somatic.vcf
│       └── tumor.vcf
└── options
    └── reference

</pre>

## Mutect2 using the Sample workflow

With the synthetic data prepared for the `Sample` workflow, running `mutect2`
is as simple as typing `rbbt workflow task Sample --workflows HTS mutect2 --jobname
ARGO-NEAT`. This will not only run the variant calling, it will also align the
BAM files from the FASTQ files. 

There are two things to note. The first is that the name of the sample is
indicated as the `--jobname` of the job, which we will see has the additional
benefit of helping manage the results. The second thing is the presence of this
flag `--workflows HTS` which indicates that the Sample workflow must be
incorporate functionalities from the `HTS` workflow, which is where alignment
and variant calling functionalities are defined. We will illustrate later how
this will allow us to easily extend our functionalities.

The provenance of the workflow we plan to use includes some new files, you can
consult it using the `--provenance` flag. The `--help` flag also shows this
provenance in a more succinct form that does not removes certain repetitions:

<pre>
Sample#mutect2
 HTS#mutect2
  HTS#mutect2_clean
   HTS#mutect2_filters
    HTS#mutect2_pre
    HTS#BAM_orientation_model
    HTS#contamination
     HTS#BAM_pileup_sumaries
 Sample#BAM
  HTS#BAM
   HTS#BAM_rescore
    HTS#BAM_sorted
     HTS#BAM_duplicates
      HTS#BAM_bwa
       HTS#uBAM
       HTS#mark_adapters
 Sample#BAM_normal
</pre>

We can recognize a portion of our previous workflow, that `HTS` part that does
the Mutect2 calling. In addition we observe a few new things. First that on top of
`HTS#mutect2` is `Sample#mutect2` this is a trivial task used only for
housekeeping purposes, it simply asks the previous one to run and links to it's
results, as we will see this makes the results more organized, hiding away all
the intermediate steps under the `HTS` workflow and leaving the `Sample`
workflow for only the interesting results. The next thing we see is a new
workflow branch under `Sample#BAM`. People initiated in the GATK best practices
for aligning short reads will recognize these steps. A similar branch would
hang under `Sample#BAM_normal`, but was abridged in this report. 

Try comparing the dependency graph we just examined with what you get from
using the `--provenance` flag. Notice the paths of the files. Under
`~/.rbbt/share/var/jobs/Sample` we will only see four files:

<pre>
/home/mvazque2/.rbbt/var/jobs/Sample/mutect2/ARGO-NEAT.vcf
/home/mvazque2/.rbbt/var/jobs/Sample/BAM/ARGO-NEAT.bam
/home/mvazque2/.rbbt/var/jobs/Sample/BAM/ARGO-NEAT_normal.bam
/home/mvazque2/.rbbt/var/jobs/Sample/BAM_normal/ARGO-NEAT.bam
</pre>

The last one is the same as the one above it. Notice that, since we didn't
override any of the default values, there is no presence of any hashes in the job
names. You can always know where to find your BAM files, VCFs, or any other
results for any sample; just like Rbbt does!

The command we presented in this section didn't have any `config_keys`. Let us
revisit this issue, since there are now a few more keys to control the
execution. To avoid having to type them all the time place the following text into
the file `~/.rbbt/etc/config_profile/HTS`

<pre>
spark false gatk
shard true gatk
cpus 18 shard 
cpus 14 haplotype
cpus 18 mutect2
cpus 15 samtools_index
cpus 15 bwa
cpus 20 sort
samtools_sort true bam_sort
threads 15 samtools_sort_threads
max_mem 2G samtools_sort_max_mem
</pre>

You may adjust the values to your particular environment, or you have have
different profiles with different values. The first line disables the SPARK
version of all GATK functions. Turning it to true will use the SPARK version
for any tool that has such a version available. In our tests found that these
can have worse performance than the sharded version. If for instance you turn
on SPARK for the MarkDuplicates step, by specifying `spark true
MarkDuplicates`, Rbbt will skip the sorting step, since the SPARK version
already outputs sorted reads. Otherwise SPARK and non-SPARK verions are mostly
equivalent. All sharding will be done over 18 different processes, except for
haplotype calling which is done over 14. Sorting of the BAM file is done using
samtools instead of GATK for performance reasons. 

We are now ready to issue our workflow `rbbt workflow task Sample -W HTS
mutect2 -jn ARGO-NEAT -ck HTS`. Note how when a config key consists only of a
single token, `HTS` in this case, it loads a file with that name found under
`etc/config_profile` directory.


