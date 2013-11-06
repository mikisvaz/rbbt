---
title: TSV Tutorial
layout: default
tagline: TSV
---

# TSV

Tab Separated Value files (TSV) are the most common format in biology, so it is
very convinient to have easy ways to manipulate them and work with them. A
proper TSV file for Rbbt is a representation of how entities, listed as the
first column, are associated to different values, specified in the rest of the
columns. Every column is identified by a header at the top of the file. The
most convinient way to programmatically access this information would be to do
something like this:

{% highlight ruby %}
tsv[key][field]
{% endhighlight %}

Where `key` is the entity we are interested in and `field` is the column which
we wish to query. The most similar structure in programming languages is the `Hash`.
The Rbbt uses hashes to load TSV files, but has the option to replace them with a 
Tokyocabinet DB transparently for fast access.

The TSV in Rbbt--one of the its most important components--strives to make
this possible for any type of data, regardless of it size, formatting details,
or provenance. Having successfully achived this, we do not need to use
databases and decide on database schemas, just query the data directly: the TSV
module will take care of everything so you have a very fast access to your
data. The cost of it is disk space and severe lags as the infrastructure
gets built the first time its needed. 

## Classification of TSV files

Typical TSV files can be classified into four classes:


{% highlight ruby %}

require 'rbbt/tsv'

text=<<-EOF
#ValueA	ValueB
A	B
a	b
EOF

text = StringIO.new(text)
tsv = TSV.open(text, :type => :single)
      
puts "A: " << tsv["A"]
puts "a: " << tsv["a"]

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
A: B
a: b
</pre></dd></dl>

Open 
