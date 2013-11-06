---
title: Resource Tutorial
layout: default
tagline: Resource
---

# Resource

The `Resource` submodule allows modules to `claim` files in specific "virtual"
locations, so that, when access, they get instantiated.

## Syntax and search paths

The syntax to access a resource is like in this example
`Rbbt.etc.configure_file` or in this one `Organism.identifiers("Hsa/jun2013")`.
These are "path" strings i.e. strings enhanced by the `Path` mixin. They have
their `method_missing` overloaded as to "grow" the path. For instance,
`Rbbt.etc.configure_file` will become `etc/configure_file`. 

These are not, however, relative paths; they are "virtual" paths. When you
declare that you want to actually open the file, the `Path` mixin will search
for it in several directories until it finds it. If it fails to find the file,
it will look into the `claim` registry to find any module that has declared
that it knows how to create it and relay that task to him. Once the file is
created it gets accessed normally; the whole process is transparent for the
calling code (except for the fact that the first time it runs it might need to
wait an indefinite time for the resource to be instantiated).

## Library layout

A workflow, package, or any other collection of functionalities that require
specific resources, can specify them relative to their root directory. The root
directory of such a package is where the `lib` directory lays. Every time a
source file specifies the need for a resource, the its root directory is
included in the search path. It it thus important to create a `lib` directory
in every project to help "root" it for the `Resource` module.

## General organization

A key principle in Rbbt is to have resources tidy and placed in reasonable
locations. The location of different resources follows the usual conventions
in Unix systems. The main directories are:

* lib: libraries of functionalities
* share: resources shared across functionalities i.e. genomic features of
  model organisms
* etc: configuration files
* var: variable data, such as caches, job results, temporary files
* www: web templates and resources
* software: locally installed software
