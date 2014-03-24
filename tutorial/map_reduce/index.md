---
title: TSV traversal
layout: default
tagline: Map-reduce in Rbbt
---

# TSV#traversal

The `TSV#traversal` takes an object that could be a `TSV`, a `Hash`, an `Array`,
a `Stream`, or a `Path` (produced, opened, and treated as a `Stream`),
and iterates through each entry executing a block of code. TSV files and
streams take the same options as when opening a TSV (`key_field`, `fields`, `sep`,
`head`, `grep`, etc).

Using the `threads` or `cpus` parameter with an integer will start that number
of threads/cpus to execute the blocks. The input elements for each execution
are placed on a queue and are consumed by workers, which compete to get the
new inputs from the queue as they finish the previous ones. For cpus the queue
is implemented using a Linux pipe (problems with concurrency in Marshal.load
have been addressed).

In order to 'reduce' the results from each block into an object, you can
specify the object with the `into` parameter. The object must be a Hash (or
TSV), in which case it will expect a pair of `key` and `value` as a return from
the block; or another hash, which will be added by `Hash#merge!`, except for
`double` TSV object in which the method `TSV#merge_zip` is used. The object can
also be anything that responds to `<<`, such as Array, Set, or Stream. Access
to the resource is protected using a mutex when using `threads`.  When using
`cpus`, the return value is piped back to the master process, which performs
the addition. If you don't plan to use concurrency to run the block or you are
using `threads` and the reduction is thread-safe, they you can do it within the
block.

Bellow you can see an example of the syntax. Note that in this example, since
it is so simple, using cpus is counter-productive, due to the overhead of
serializing/deserializing through the pipe, starting and monitoring the
processes, etc. Also the particular problem it solves could have been
implemented otherwise more simply. If you execute this example, you can play
around with different values for the `threads` and `cpus` parameters (`cpus`
will be ignored if `threads` are specified)

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/sources/organism'

# TSV#traversal currently ignores named arrays and entities except for
# real TSV traversal; not for streams as in this case. so we need 
# to find the position like this
uniprot_pos = Organism.identifiers("Hsa").fields.index "UniProt/SwissProt Accession"

has_uniprot = []
TSV.traverse Organism.identifiers("Hsa"), :cpus => 3, :into => has_uniprot do |k,v|
  if v[uniprot_pos].any?
    k
  else
    next
  end
end

puts "Ensembl Gene IDs with UniProt equivalences: #{has_uniprot.compact.length}"

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
Ensembl Gene IDs with UniProt equivalences: 20784
</pre></dd></dl>

The following example merges the result into a hash object. The result of each
iteration, a Hash, is merged into the hash. It also illustrates using options
to parse the stream; in this case the stream is treated as a `flat` TSV.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/sources/organism'

uni2ens = {}
TSV.traverse Organism.identifiers("Hsa"), 
  :fields => ["UniProt/SwissProt Accession"], :type => :flat,
  :cpus => 3, :into => uni2ens do |k,unis|

  matches = {}
  unis.each do |uni|
    matches[uni] = k
  end
  matches
end

puts "UniProt entries: #{uni2ens.keys.length}"
puts "Ensembl entries (uniq): #{uni2ens.values.compact.flatten.uniq.length}"

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
UniProt entries: 19079
Ensembl entries (uniq): 18974
</pre></dd></dl>

The discrepancy in the number of Ensembl entries comes from the fact that some
UniProt ids are assigned to several Ensembl Gene IDs, and the `Hash#merge!`
method will override each entry with the next. In fact, when running
concurrently, that number varies from execution to execution, as entries are
treated in different order. 

To avoid this in the next example we 'reduce' into a `double` TSV; the
`TSV#merge_zip` takes care of accumulating the values instead of overwriting
them.

{% highlight ruby %}

require 'rbbt-util'
require 'rbbt/sources/organism'

uni2ens = TSV.setup({}, :key_field => "UniProt/SwissProt Accession", 
                  :fields => ["Ensembl Gene ID"], :type => :double)

TSV.traverse Organism.identifiers("Hsa"), 
  :fields => ["UniProt/SwissProt Accession"], :type => :flat,
  :cpus => 3, :into => uni2ens do |k,unis|

  matches = {}
  unis.each do |uni|
    matches[uni] = [k]
  end
  matches
end

puts "UniProt entries: #{uni2ens.keys.length}"
puts "Ensembl entries (uniq): #{uni2ens.values.compact.flatten.uniq.length}"

{% endhighlight %}
<dl class='result'><dt>Result</dt><dd><pre>
UniProt entries: 19079
Ensembl entries (uniq): 20784
</pre></dd></dl>
