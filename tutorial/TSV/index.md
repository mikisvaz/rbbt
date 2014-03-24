---
title: TSV Tutorial
layout: default
tagline: TSV
---

# TSV

Tab Separated Value files (TSV) is one of the most common formats in biology,
so it is very convenient to have easy ways to manipulate and work with them.  A
proper TSV file for Rbbt is a representation of how entities, listed as the
first column, are associated to different values, specified in the rest of the
columns. Every column is identified by a header at the top of the file.  The
most convinient way to programmatically access this information would be to do
something like this:

{% highlight ruby %}
tsv[key][field]
{% endhighlight %}

Where `key` is the entity we are interested in and `field` is the column which
we wish to query. The most similar structure in programming languages is the `Hash`.
The Rbbt uses hashes to load TSV files, but has the option to replace them with a 
Tokyocabinet DB transparently for fast access.

The TSV in Rbbt--one of its most important components--strives to make
this possible for any type of data, regardless of it size, formatting details,
or provenance. Having successfully achived this, we do not need to use
databases and decide on database schemas, just query the data directly: the TSV
module will take care of everything so you have a very fast access to your
data. The cost of it is disk space and severe lags as the infrastructure
gets built the first time its needed. 

## Classification of TSV files

Typical TSV files can be classified into four classes.

The following code opens reads a TSV file as a `:single` TSV. Here
each entry of the resulting hash contains a single value.

{% highlight ruby %}

require 'rbbt/tsv'

text=<<-EOF
#ValueA	ValueB
A B
a b
EOF

text = StringIO.new(text)
tsv = TSV.open(text, :type => :single, :sep => " ")
      
puts "A: " << tsv["A"]
puts "a: " << tsv["a"]

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
A: B
a: b
</pre></dd></dl>

In this next case the keys are not associated with a single value, but with a
list of values. This TSV are of type `:list`.

{% highlight ruby %}

require 'rbbt/tsv'

text=<<-EOF
#ValueA	ValueB ValueC
A B C
a b c
EOF

text = StringIO.new(text)
tsv = TSV.open(text, :type => :list, :sep => " ")
      
puts "A ValueB: " << tsv["A"]["ValueB"] 
puts "A ValueC: " << tsv["A"]["ValueC"] 
puts "a ValueB: " << tsv["a"]["ValueB"] 
puts "a ValueC: " << tsv["a"]["ValueC"] 

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
A ValueB: B
A ValueC: C
a ValueB: b
a ValueC: c
</pre></dd></dl>

In the following example, the TSV file lists multiple values for a single
field: type `:flat`.

{% highlight ruby %}

require 'rbbt/tsv'

text=<<-EOF
#ValueA	ValueB
A B|BB|BBB 
a b|bb|bbb
EOF

text = StringIO.new(text)
tsv = TSV.open(text, :type => :flat, :sep => " ")
      
puts "A values: " << tsv["A"] * ", " 
puts "a values: " << tsv["a"] * ", "

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
A values: B, BB, BBB
a values: b, bb, bbb
</pre></dd></dl>

Finally, `:double` TSV have values which are lists of lists.

{% highlight ruby %}

require 'rbbt/tsv'

text=<<-EOF
#ValueA	ValueB ValueC
A B|BB|BBB C|CC|CCC
a b|bb|bbb c|cc|ccc
EOF

text = StringIO.new(text)
tsv = TSV.open(text, :type => :double, :sep => " ")
      
puts "A ValueB: " << tsv["A"]["ValueB"] * ", "
puts "A ValueC: " << tsv["A"]["ValueC"] * ", "
puts "a ValueB: " << tsv["a"]["ValueB"] * ", "
puts "a ValueC: " << tsv["a"]["ValueC"] * ", "

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
A ValueB: B, BB, BBB
A ValueC: C, CC, CCC
a ValueB: b, bb, bbb
a ValueC: c, cc, ccc
</pre></dd></dl>
