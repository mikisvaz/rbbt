---
title: Get started
layout: default
tagline: Getting started with Rbbt
---

Getting started with Rbbt
=========================

Overview
-------------
Rbbt stands for Ruby Bioinformatics Toolkit and as such can be seen as a collection of tools to perform bioinformatics. These basic building blocks of Rbbt are found in Ruby gems and they include code for things like gather data resources and create databases and indices to query them, create and enact workflows, or export functionalities through HTTP and REST. These ruby gems are the rbbt core system and are very simple to install.

Code is just one side of the coin in bioinformatics or any other data-intensitive field, the other is of course data. Beyond the basic task implemented in the Rbbt core system are what we can call _functionalities_, this very general term is used to refer to anything from a lengthy analysis to a query system answering questions in real time. Bioinformatics functionalities typically require auxiliary datasets (such as files with basic genomic information) and some level of infrastructure (indices to query them). Rbbt implements a resource management system that will take care of gathering the data you need  (or even thir party software) and preparing it for use. This means that while this process will take require no action on the part of the user it might lead to a significant delay when an infrastructure is first use. Producing this infrastructure is what we call bootstrapping, and is the most important part getting Rbbt ready for use. 

In Rbbt functionalities are packaged in what we call **workflows**, which include the code to bootstrap the infrastructure and the pipelines of analysis that implement these functionalities. Rbbt offers access to these functionalities via the commandline, programmatically, through REST web services, and through HTML templates. This scheme help us reuse and repurpose functionalities and analytical pipelines in Rbbt ofent involve may workflows, specially when implementing omics analysis. Additionally the Workflows can overide the boilerplate templates used to offer access to the functionalities via HTML to build incrementally more complex user interfaces.

Because bootstrapping and infrastructure might be very expensive, or require data that is not made available publically, in Rbbt we often provide remote access to some functionalities. In Rbbt you can specify which workflows you want to use remotely and all your analytical pipeline will transparently relay that work to them, thus avoiding the use of any local infrastructure for those functionalities.

Intallation
--------------

The first step in an Rbbt installation is to install the base system and the Ruby gems. This basically just means having Ruby installed and the Rbbt gems. However to fully use Rbbt a there are a few details that need to be worked out. The `rbbt-image` gem provides a convenient tool to produce _provision_ files for docker images and virtual machines that will install the base system. 

Below is an except of the section that prepares the base system in Ubuntu. As you can see it install a few packages and does a couple of final touches to the installation. The last part install Ruby without the use of the Ubuntu package manager, and is there to ensure the same ruby version is shared across our docker images, you can safely skip it and use the system version or use [rvm](https://rvm.io/), which is what I tend to use myself.

```sh
# INSTALL
# =======

# Basic system requirements
# -------------------------
apt-get -y update
apt-get -y update
apt-get -y install \
  bison autoconf g++ libxslt1-dev make \
  zlib1g-dev libbz2-dev libreadline6 libreadline6-dev \
  wget curl git openssl libyaml-0-2 libyaml-dev \
  ruby2.0 ruby-dev \
  r-base-core r-base-dev r-cran-rserve \
  openjdk-7-jdk \
  libtokyocabinet-dev tokyocabinet-bin \
  build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libffi-dev


grep R_HOME /etc/profile || echo "export R_HOME='/usr/lib/R' # For Ruby's RSRuby gem" >> /etc/profile
. /etc/profile

# This link was broken for some reason
rm /usr/lib/R/bin/Rserve
ln -s /usr/lib/R/site-library/Rserve/libs/Rserve /usr/lib/R/bin/Rserve

# RUBY INSTALL
# ============

cd /tmp
wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
tar -xvzf ruby-2.3.1.tar.gz
cd ruby-2.3.1/
./configure --prefix=/usr/local
make && make install

grep "#Ruby2" /etc/profile || echo 'export PATH="/usr/local/bin:$PATH" #Ruby2' >> /etc/profile
. /etc/profile
``` 

After the base system is installed we need to install the Rbbt gems and some of its dependencies. Rbbt and its workflows have a very large scope of functionalities and thus many dependencies. Since not all of these dependencies are always needed they are strictly require, thus the following code installs the most important ones explicitly. 

```sh
# RUBY GEMS and RBBT
# =================

export REALLY_GEM_UPDATE_SYSTEM=true
env REALLY_GEM_UPDATE_SYSTEM=true gem update --no-ri --no-rdoc --system
gem install --force --no-ri --no-rdoc ZenTest
gem install --force --no-ri --no-rdoc RubyInline

# R (extra config in gem)
gem install --conservative --no-ri --no-rdoc rsruby -- --with-R-dir=/usr/lib/R --with-R-include=/usr/share/R/include --with_cflags="-fPIC -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wall -fno-strict-aliasing"

# Java (extra config in gem)
export JAVA_HOME=$(echo /usr/lib/jvm/java-7-openjdk-*)
gem install --conservative --force --no-ri --no-rdoc rjb

# Rbbt and some optional gems
gem install --no-ri --no-rdoc --force \
    tokyocabinet \
    ruby-prof \
    rbbt-util rbbt-rest rbbt-dm rbbt-text rbbt-sources rbbt-phgx rbbt-GE \
    rserve-client \
    uglifier therubyracer kramdown\
    puma

# Get good version of lockfile
wget http://ubio.bioinfo.cnio.es/people/mvazquezg/lockfile-2.1.4.gem -O /tmp/lockfile-2.1.4.gem
gem install --no-ri --no-rdoc /tmp/lockfile-2.1.4.gem

# Extra things for web interface
gem install --no-ri --no-rdoc bio-svgenes mimemagic
```
The previous steps where used to configure a the docker image [mikisvaz/rbbt-basic](https://hub.docker.com/r/mikisvaz/rbbt-basic/), which you can use instead. Just remember that whenever you see `rbbt` from here on you should write `docker run -it mikisvaz/rbbt-basic rbbt`. 

Usage
--------
### The `rbbt` command
After the installation steps above we are ready to use rbbt. The main way to interact with the system is via de command `rbbt` which offers a convenient way to access many different tools. Its use is similar to other commands line `git` and follows the general sytax `rbbt command subcommand1 subcommand2 --option1 --option2 arg1 arg2`. As you time commands it will show you the subcommands available, and you can always use the `-h` flag to get help on the available options. 

The tools available include examining TSV files, monitoring the system status, configuring remote workflows, initiating web servers, and most importantly enacting workflow tasks. Lets look a that in more detail.

### Workflow enactment in Rbbt
The most basic way to enact a workflow task is using the `rbbt` command as follows `rbbt workflow task <workflow> <task> <options>` for example, to translate the gene symbol _TP53_ to Ensembl ID you would run the following command (see the following sub-section before trying it out!):

```sh
rbbt workflow task Translation translate --gene TP53 --format "Ensembl Gene ID"
```
This command will output through `STDOUT` the code _ENSG00000141510_, as well some logs via the `STDERR`.  To get more help on this command you can type `rbbt workflow task Translation translate -h` to see the available options[^organism_footnote] and even some examples. 

[^organism_footnote]: You might notice the `organism` options, this is a very important option that allows all our workflows to be perfectly in sync with regards to their versions of genomic data, just know that `Hsa` stands for **H**omo **sa**piens, with data gathered from the `feb2014` version of the Ensembl archives (remember how the we discussed that data files where gathered automatically in Rbbt?). If you wanted to translate mouse genes you coud have written `Mmu/feb2014`. Also, note that gene symbols are case sensitive, human genes are uppercase, mouse genes are not.

#### Using a remote workflow
Running the command above would started the gathering of certain data files fomr the Ensembl BioMart and creating some indices to access them, i.e. boostrapping some of the Translation workflow infrastructure. Queries to the Ensembl BioMart take a little while and you would end up probably interrupting the process and with a bad feeling about it. Instead let us first try to run the same command on one of the workflow servers mantained at CNIO.
```sh
rbbt workflow task http://rbbt.bioinfo.cnio.es/Translation translate --genes TP53 --format "Ensembl Gene ID"
```
Alternatively you can also configure the Translation workflow to always use that remote sever so that you can just write `Translation`
```sh 
rbbt workflow remote add Translation http://rbbt.bioinfo.cnio.es/Translation
```
If you would like to install the infrastructure locally you can remove the remote server (if you created it)
```sh 
rbbt workflow remote remove Translation
```
install the workflow locally (the code)
```sh 
rbbt workflow install Translation
```
or alternative do `export RBBT_WORKFLOW_AUTOINSTALL=true' to have workflows autoinstall as needed. And run the command as initially, though in this case with a more verbose log level so you can monitor the process
```sh
rbbt workflow task Translation translate --gene TP53 --format "Ensembl Gene ID" --log 0
```

What next
========
You have now gotten started with Rbbt. The next thing you can do is find interesting workflows you might want to check out at [https://github.com/Rbbt-Workflows](https://github.com/Rbbt-Workflows), or think of writing your own.
