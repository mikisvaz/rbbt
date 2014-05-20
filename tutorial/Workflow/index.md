---
title: Workflow Tutorial
layout: default
tagline: Workflow overview
---

# Workflows in Rbbt

Workflows in Rbbt are installed in predefined locations. The default location
is `~/.rbbt/workflows` but it can be redefined with a different directory
by placing it on `~/.rbbt/etc/workflow_dir`. You can place the workflow in the
directory manually, or you can install it automatically from source using
the following command:

{% highlight bash %}
rbbt workflow install <workflow>
{% endhighlight %}

This command will download the workflow from http://github.com/Rbbt-Workflows.
It will also update the workflow to the latest git revision. You can see
a list of installed workflows doing `rbbt workflow list`.

To use the workflow you can again use the rbbt command: `rbbt workflow task <workflow>`. 
Issuing that command will list the available tasks for the
workflow. You can then do `rbbt workflow task <workflow> <task> -h` to learn
how to use each particular task.

Workflows may require extensive resources, such a genomics data, fast access
key-value stores, caches, indices, etc. These get created on demand. In order
to help the initial process, some workflows include a `bootstrap` script, that
will issue a number of jobs that will prompt the installation of this
infrastructure. Workflow commands are issued using the `rbbt` command: 
`rbbt workflow cmd <workflow>` will list the available commands for that workflow.
To issue the bootstrap do `rbbt workflow cmd <workflow> bootstrap`.

To cut down setup time even more, you can configure remote file servers to
gather resources from an already configured server. See the installation
instructions for more information.

In the cases where the setup of the workflows infrastructure becomes to costly,
you may also configure a remote workflow. This will forward all work
transparently to the remote server. This is specially recommended for the
`MutEval` workflow, which uses the
[dbSNFP](https://sites.google.com/site/jpopgen/dbNSFP) resource for protein
mutation damage predictions, and is over thirty gigabytes in size.

File servers and remote workflows are served from any Rbbt REST server.
Currently you may use http://se.bioinfo.cnio.es.

You may start you own REST interface for a workflow issuing the following
command `rbbt workflow server <workflow>`.
