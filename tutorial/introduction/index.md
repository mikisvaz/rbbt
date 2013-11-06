---
title: Introduction
layout: default
tagline: Rbbt introduction
---

# Introduction

The Rbbt system is a collection of functionalities (tools in the toolbox)
organized into an API. These functionalities are powered by one another and
by a sophisticated infrastructure of resources.

The Rbbt has the `Workflow` module to package functionalities. These can be
accessed any of the following ways:

* Programmatically from Ruby
* From the command-line through the `rbbt` command
* Through the HTML interface
* Through the REST web server using a programmatic API

Implementing workflows is simplified thanks to the extensive collection of
tools in Rbbt. The can be maintained independently from the base system, and
managed through the `rbbt` command to install or update them from different
sources.

Any software that uses Rbbt will tap into the same infrastructure, sharing not
only the functionalities and resources, but also the caches, indexes and
analysis results that get created over time.

## Objectives

There are several objectives that the Rbbt framework tries to achieve:

* Complete reproducibility and provenance
* Complete re-usability
* Promoting of good development practices by using incentives
* Being flexible and un-intrusive; standards and practices can be ignored and
  worked around for particular cases
* Providing an executable _domain specific language_ (DSL) that can best express the
  processes in bioinformatics.
* Allowing the best tool to be used for each task; i.e. R for data analysis,
  Sinatra, HAML & SASS for web development, shell scripts for system
  administration, basic Unix/Linux tools for efficient file processing, etc
* Achieving production-ready performance in basic operations, even over
  databases of millions of rows, without sacrificing simplicity

Achieving these objectives in Rbbt took many years and the development of
several programming paradigms, which use extensively Ruby meta-programming
capabilities. While the inner workings of the framework are very elaborate, the
final DSL is very expressive and succinct.


