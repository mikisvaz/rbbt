---
title: Command-line
layout: default
tagline: The `rbbt` command line utility
---

# Overview

The rbbt command line tool comes in the rbbt-util gem. To update the basic rbbt-util package and the rbbt command do

```bash
gem update rbbt-util
```
The rbbt command is basically a wrapper that finds a particular script and executes it. Typing rbbt will show the list of first level
commands. Some of these are scripts, some of them are directories containing more scripts. You may append subcommands until
you reach a script; which will execute it with the rest of the parameters. The rbbt command line also consumes a couple of command line
parameters, such as the --log, which specifies the level of logging to use (0 for debug, 4 for default level, 7 or more no logs at all)

Some of the most important commands are the following:

    rbbt workflow
        rbbt workflow list: See all installed workflows
        rbbt workflow install: Install new workflows from github
        rbbt workflow remote
            rbbt workflow remote {add|list|remove}: Add/list/remove remote workflows
        rbbt workflow task: Examine, execute and monitor workflow tasks
    rbbt tsv
        rbbt tsv info: Display some general information about a tsv file (field names, number of entries, ect)
        rbbt tsv change_id: Change columns between formats

