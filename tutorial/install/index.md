---
title: Install
layout: default
tagline: Rbbt install
---

# Install

There are three parts to the installation:

* Install the base-system
* Configure Rbbt
* Bootstrap the installation

Note that Rbbt has been developed for Unix/Linux systems. Mac OS X, being based
on Unix, works as well. I haven't tried to run it on Windows, but I'm almost
sure it will not work.

## Base-system

Installing the base-system amounts to installing some system packages, ruby,
and some ruby gems. Except for a couple of gems, which require a bit of
configuration, all the installation is straight forward.  

To ease installation I have prepare a `Vagrant` installation
[here](https://github.com/mikisvaz/rbbt-vagrant). The `bootstrap.sh` script
contains all the necessary steps to setup the base system on an Ubuntu box. 
The step should be easy to adapt for other installations.

In my own work, I like to install ruby locally from my user account through
[RVM](https://rvm.io/).

## Configuration and Bootstrapping

The functionalities in Rbbt require an extensive infrastructure composed of
data resources, indexes and caches. This infrastructure gets instantiated on
demand, but it can take a while to get setup on a new installation. The Rbbt
manages this infrastructure very effectively, and can be setup so that
resources can be shared across different users of a system or even between
systems. However, a new installation will require bootstrapping the complete
infrastructure.

One of the most time consuming steps is the production of some data resources,
most notably basic genomic data from model organisms, which requires
downloading long files from BioMart and processing them to get them tidy. To
avoid this step, you can setup `file_servers` that will serve these resources
already prepared. `rbbt file_server add Organism http://se.bioinfo.cnio.es/`.
When a resource needs to be produce, the `file_servers` will be checked to see
if they can serve that file, if not, it will be produced normally.

Additionally, particular workflows can be delegated to other servers
(`remote_workflows`), which can be done as follows `rbbt workflow remote add
Sequence http://se.bioinfo.cnio.es`.

### Quick recipie

Provided your linux distribution has the right packages, you should be able to
install the system by running the following script

{% highlight sh %}

\curl -L https://get.rvm.io | bash -s stable --auto-dotfiles
source ~/.profile
rvm reload
rvm autolibs disable
rvm install ruby-2.0.0
gem install --no-ri --no-rdoc tokyocabinet uglifier therubyracer kramdown ruby-prof \
    rbbt-util rbbt-rest rbbt-study rbbt-dm rbbt-text rbbt-sources rbbt-phgx rbbt-GE 

{% endhighlight %}

If this fails, do `rvm requirements` and install (or ask someone to install)
these packages.
