require 'rbbt'


# This module holds helper methods to deal with the Gene Ontology files. Right
# now all it does is provide a translation form id to the actual names.
module GO

  @@info = nil
  MULTIPLE_VALUE_FIELDS = %w(is_a)

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
            if MULTIPLE_VALUE_FIELDS.include? key.strip
              term_info[key.strip] ||= []
              term_info[key.strip] << value.strip
            else
              term_info[key.strip] = value.strip
            end
          }
        @@info[term_info["id"]] = term_info
    }
  end

  def self.info
    self.init unless @@info
    @@info
  end

  def self.goterms
    self.init unless @@info
    @@info.keys
  end

  def self.id2name(id)
    self.init unless @@info
    if id.kind_of? Array
      @@info.values_at(*id).collect{|i| i['name'] if i}
    else
      return nil if @@info[id].nil?
      @@info[id]['name']
    end
  end

  def self.id2ancestors(id)
    self.init unless @@info
    if id.kind_of? Array
      @@info.values_at(*id).
        select{|i| ! i['is_a'].nil?}.
        collect{|i| i['is_a'].collect{|id| 
          id.match(/(GO:\d+)/)[1] if id.match(/(GO:\d+)/)
        }.compact
      }
    else
      return [] if @@info[id].nil? || @@info[id]['is_a'].nil?
      @@info[id]['is_a'].
        collect{|id| 
        id.match(/(GO:\d+)/)[1] if id.match(/(GO:\d+)/)
      }.compact
    end
  end

  def self.id2namespace(id)
    self.init unless @@info
    if id.kind_of? Array
      @@info.values_at(*id).collect{|i| i['namespace'] if i}
    else
      return nil if @@info[id].nil?
      @@info[id]['namespace']
    end
  end


end
