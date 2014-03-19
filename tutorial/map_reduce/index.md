---
title: TSV traversal
layout: default
tagline: Map-reduce in Rbbt
---

# TSV#traversal

The TSV#traversal takes an object that could be a `TSV`, a `Hash`, an `Array`
and iterates through each entry executing a block of code. TSV files and
streams take the same options as when opening a TSV (`key_field`, `fields`, `sep`,
`head`, `grep`, etc).

Using the `threads` or `cpus` parameter with an integer will start that number
of threads/cpus to execute the blocks. The input elements for each execution
are placed on a queue and are consumed by workers, which compete to get the
new inputs from the queue as they finish the previous ones. For cpus the queue
is implemented using a linux pipe (problems with concurrency in Marshal.load
have been addressed).

In order to 'reduce' the results from each block into an object, you can
specify the object with the `into` parameter. The object must be a Hash (or
TSV), in which case it will expect a pair of `key` and `value` as a return from
the block, or is can be anything that responds to `<<`, such as Array, Set, or
Stream. Access to the resource is protected using a mutex when using `threads`.
When using `cpus`, the return value is piped back to the master process, which
performs the addition.

Bellow you can see an example of the syntax. Note that in this example, using
cpus is quite slow, due to the overhead or serializing/deserializing through
the pipe, etc. Also the particular problem it solves could have been
implemented otherwise more simply.

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

<dl class='result'><dt>Result</dt><dd><pre>
Ensembl Gene IDs with UniProt equivalences: 20784
</pre></dd></dl>
