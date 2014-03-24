---
title: Command-line
layout: default
tagline: The `rbbt` command line utility
---

# Overview

The rbbt command line tool comes in the rbbt-util gem. To update the basic rbbt-util package and the rbbt command do

{% highlight bash %}
gem update rbbt-util
{% endhighlight %}

The rbbt command is basically a wrapper that finds a particular script and
executes it. Typing rbbt will show the list of first level commands. Some of
these are scripts, some of them are directories containing more scripts. You
may append subcommands until you reach a script; which will execute it with the
rest of the parameters. The rbbt command line also consumes a couple of command
line parameters, such as the --log, which specifies the level of logging to use
(0 for debug, 4 for default level, 7 or more no logs at all).

Rbbt does not enforce any particular practice on the command scripts, it just
loads them. If a command is anything but trivial, it commonly uses Rbbt's
`rbbt/util/simpleopt` module. Among other things, this means most command-line
parameters are assigned a shorthand version. This shorthand version is
determined automatically for workflow tasks. You may find these in the
command-line documentation with -h.

Some of the most important commands are the following:

* rbbt workflow
    * rbbt workflow list: See all installed workflows
    * rbbt workflow install: Install new workflows from github
    * rbbt workflow remote
        * rbbt workflow remote {add|list|remove}: Add/list/remove remote workflows
    * rbbt workflow task: Examine, execute and monitor workflow tasks
    * rbbt workflow server: Start a http server with a REST interface that can be contacted through the browser or as a remote workflow
* rbbt tsv
    * rbbt tsv info: Display some general information about a tsv file (field names, number of entries, ect)
    * rbbt tsv change_id: Change columns between formats

Each command is free to implement its functionality however it wants. Unless the command is very
simple, it usually displays help with the '-h' parameter.  If they are badly documented you can always
examine the code using the --locate_file to find the path to the actual script file. 

{% highlight bash %}
rbbt workflow task --locate_file
{% endhighlight %}

When commands get to long and are tedious to write, you can make use of aliases. These work as follows

{% highlight bash %}
rbbt alias <alias_name> <commands_and_parameters>
{% endhighlight %}

for example:

{% highlight bash %}
rbbt alias gene_name workflow task Translation translate -f "Associated Gene Name"
{% endhighlight %}

Which will transform:

{% highlight bash %}
rbbt gene_name -g ensembl.txt
{% endhighlight %}

into:

{% highlight bash %}
rbbt workflow task Translation translate -f "Associated Gene Name" -g ensembl.txt
{% endhighlight %}

# Practical examples

The most common command you will probably be using will be `rbbt workflow task`. 
Typing `rbbt workflow task <wofkflowname>` will display all the tasks that this
workflow makes available. Typing `rbbt workflow task <workflowname> <taskname> -h`
will display a summary of the task parameters. Each parameter is associated with a 
task `input`.

Executed tasks are, by default, ran synchronously, with persistence, and the
result file is printed to STDOUT. Alternatively, one can list and recover task files
that where produced during the execution, re-run the job by using `--clean` or 
`--recursive_clean` to re-run also its dependencies, run the job in the background and
monitor its status, etc.

Remote workflow can also be interfaced transparently through the rbbt command, but some 
functionalities may not be available.

A few interesting workflow tasks are:

* `rbbt workflow task Translation translate`: Translate a list of genes ids to another format (see a post about this)
* `rbbt workflow task Genomics names`: Takes a tsv file and translates all identified entities to a their human-friendly names

