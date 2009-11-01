require 'rbbt'


# This module holds helper methods to deal with the Gene Ontology files. Right
# now all it does is provide a translation form id to the actual names.
module GO
  @@info = nil

  # This method needs to be called before any translations can be made, it is
  # called automatically the first time the id2name method is called. It loads
  # the gene_ontology.obo file and extracts all the fields, although right now,
  # only the name field is used.
  def self.init
    @@info = {}
    File.open(File.join(Rbbt.datadir, 'dbs/go/gene_ontology.obo')).read.
      split(/\[Term\]/).
      each{|term| 
        term_info = {}
        term.split(/\n/).
          select{|l| l =~ /:/}.
          each{|l| 
            key, value = l.chomp.match(/(.*?):(.*)/).values_at(1,2)
            term_info[key.strip] = value.strip
          }
        @@info[term_info["id"]] = term_info
      }
  end

  def self.id2name(id)
    self.init unless @@info
    if id.kind_of? Array
      @@info.values_at(*id).collect{|i| i['name'] if i}
    else
      return "Name not found" unless @@info[id]
      @@info[id]['name']
    end
  end


end