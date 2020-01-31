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
on Unix, so to speak, works as well. I haven't tried to run it on Windows, but
I'm almost sure it will not work.

## Base-system

Installing the base-system amounts to installing some system packages, ruby,
and some ruby gems. Except for a couple of gems, which require a bit of
configuration, all the installation is straight forward.  

There is a gem called rbbt-image that contains the necesary scripts to
provision docker containers and vagrant images and that can be used also to
provision a normal account. There is no need for root access except to install
some base packages. In the organization [Rbbt-Images](https://github.com/Rbbt-Images) 
you can find several repos used to create docker images and include provision
files that can be used as reference.

For a minimal installation:

```bash

# Basic system requirements
# -------------------------
apt-get -y update
apt-get -y update
apt-get -y install \
  bison autoconf g++ libxslt1-dev make \
  zlib1g-dev libbz2-dev libreadline-dev \
  wget curl git openssl libyaml-0-2 libyaml-dev \
  openjdk-8-jdk \
  libcairo2 libcairo2-dev r-base-core r-base-dev r-cran-rserve liblzma5 liblzma-dev libcurl4-openssl-dev \
  build-essential zlib1g-dev libssl-dev libyaml-dev libffi-dev ruby-dev ruby-tokyocabinet

# Rbbt and some optional gems
gem install --no-ri --no-rdoc --force rbbt-util rbbt-rest rbbt-dm rbbt-sources 

```


For a more comprehensive installation:

```bash

# Basic system requirements
# -------------------------
apt-get -y update
apt-get -y update
apt-get -y install \
  bison autoconf g++ libxslt1-dev make \
  zlib1g-dev libbz2-dev libreadline-dev \
  wget curl git openssl libyaml-0-2 libyaml-dev \
  openjdk-8-jdk \
  libcairo2 libcairo2-dev r-base-core r-base-dev r-cran-rserve liblzma5 liblzma-dev libcurl4-openssl-dev \
  build-essential zlib1g-dev libssl-dev libyaml-dev libffi-dev

# This link was broken for some reason
rm /usr/lib/R/bin/Rserve
ln -s /usr/lib/R/site-library/Rserve/libs/Rserve /usr/lib/R/bin/Rserve

grep R_HOME /etc/profile || echo "export R_HOME='/usr/lib/R' # For Ruby's RSRuby gem" >> /etc/profile
. /etc/profile

# TOKYOCABINET INSTALL
# ===================

cd /tmp
wget http://fallabs.com/tokyocabinet/tokyocabinet-1.4.48.tar.gz -O "tokyocabinet.tar.gz"
tar -xvzf tokyocabinet.tar.gz
cd tokyocabinet-1.4.48
./configure --prefix=/usr/local
make && make install

echo "3. Setting up ruby"
export RUBY_VERSION='2.4.1'
#!/bin/bash -x

# RUBY INSTALL
# ============

_small_version=`echo $RUBY_VERSION | cut -f 1,2 -d.`
cd /tmp
wget https://cache.ruby-lang.org/pub/ruby/$_small_version/ruby-${RUBY_VERSION}.tar.gz -O "ruby.tar.gz"
tar -xvzf ruby.tar.gz
cd ruby-*/
./configure --prefix=/usr/local
make && make install

unset _small_version

grep '#Ruby2' /etc/profile || echo 'export PATH="/usr/local/bin:$PATH" #Ruby2' >> /etc/profile
. /etc/profile

. /etc/profile

export REALLY_GEM_UPDATE_SYSTEM=true
env REALLY_GEM_UPDATE_SYSTEM=true gem update --no-ri --no-rdoc --system
gem install --force --no-ri --no-rdoc ZenTest
gem install --force --no-ri --no-rdoc RubyInline

# R (extra config in gem)
. /etc/profile
export R_INCLUDE="$(echo "$R_HOME" | sed 's@/usr/lib\(32\|64\)*@/usr/share@')/include"
gem install --conservative --no-ri --no-rdoc rsruby -- --with-R-dir="$R_HOME" --with-R-include="$R_INCLUDE" \
  --with_cflags="-fPIC -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wall -fno-strict-aliasing"

# Java (extra config in gem)
export JAVA_HOME=$(echo /usr/lib/jvm/java-?-openjdk-*)
gem install --conservative --force --no-ri --no-rdoc rjb

# Rbbt and some optional gems
gem install --no-ri --no-rdoc --force \
    tokyocabinet \
    ruby-prof \
    rbbt-util rbbt-rest rbbt-dm rbbt-text rbbt-sources \
    rserve-client \
    uglifier therubyracer kramdown\
    puma

# Get good version of lockfile
wget http://ubio.bioinfo.cnio.es/people/mvazquezg/lockfile-2.1.4.gem -O /tmp/lockfile-2.1.4.gem
gem install --no-ri --no-rdoc /tmp/lockfile-2.1.4.gem
gem install --no-ri --no-rdoc bio-svgenes mimemagic



```

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

When the system is configured, it is a good idea to bootstrap it. Many
workflows include a `bootstrap` command, which run a series of dummy jobs to
ensure all the necessary resources are claimed and indices and caches are made.
Bootstrapping a workflow is done using the `rbbt` command like in the following
example:

{% highlight sh %}
rbbt workflow cmd Enrichment bootstrap 30
{% endhighlight %}

Where 30 is the number of concurrent jobs to issue (I run this on a 31 core
machine). Concurrent jobs will organize to build the necessary infrastructure
in an orderly manner.

### Quick recipie

Provided your Linux distribution has the right packages, you should be able to
install the system by running the following script

{% highlight sh %}

\curl -L https://get.rvm.io | bash -s stable --auto-dotfiles
source ~/.profile
rvm reload
rvm autolibs disable
rvm install ruby-1.9.3
gem install --no-ri --no-rdoc tokyocabinet \
  uglifier therubyracer kramdown ruby-prof \
  rbbt-util rbbt-rest rbbt-study rbbt-dm rbbt-text rbbt-sources rbbt-phgx rbbt-GE 

{% endhighlight %}

If this fails, do `rvm requirements` and install (or ask someone to install)
these packages.
