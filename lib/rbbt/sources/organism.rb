require 'rbbt'
require 'rbbt/util/open'
require 'rbbt/util/index'

# This module contains some Organism centric functionalities. Each organism is
# identified by a keyword.
module Organism

  # Raised when trying to access information for an organism that has not been
  # prepared already.
  class OrganismNotProcessedError < StandardError; end

  # Return the list of all supported organisms. The prepared flag is used to
  # show only those that have been prepared.
  def self.all(prepared = true)
    if prepared
      Dir.glob(File.join(Rbbt.datadir,'/organisms/') + '/*/identifiers').collect{|f| File.basename(File.dirname(f))}
    else
      Dir.glob(File.join(Rbbt.datadir,'/organisms/') + '/*').select{|f| File.directory? f}.collect{|f| File.basename(f)}
    end
  end


  # Return the complete name of an organism. The org parameter is the organism
  # keyword
  def self.name(org)
    raise OrganismNotProcessedError, "Missing 'name' file" if ! File.exists? File.join(Rbbt.datadir,"organisms/#{ org }/name")
    Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/name"))
  end

  # Hash linking all the organism log names with their keywords in Rbbt. Its
  # the inverse of the name method.
  NAME2ORG = {}
  Organism::all.each{|org|  
    name = Organism.name(org).strip.downcase
    NAME2ORG[name] = org
  }


  # Return the key word associated with an organism.
  def self.name2org(name)  
    NAME2ORG[name.strip.downcase]
  end

  # FIXME: The NER related stuff is harder to install, thats why we hide the
  # requires next to where they are needed, next to options
  
  # Return a NER object which could be of RNER, Abner or Banner class, this is
  # selected using the type parameter. 
  def self.ner(org, type=:rner, options = {})

    case type.to_sym
    when :abner
      require 'rbbt/ner/abner'
      return Abner.new
    when :banner
      require 'rbbt/ner/banner'
      return Banner.new
    when :rner
      require 'rbbt/ner/rner'
      model = options[:model] 
      model ||= File.join(Rbbt.datadir,"ner/model/#{ org }") if File.exist? File.join(Rbbt.datadir,"ner/model/#{ org }")
      model ||= File.join(Rbbt.datadir,'ner/model/BC2')
      return NER.new(model)
    else
      raise "Ner type (#{ type }) unknown"
    end

  end

  # Return a normalization object.
  def self.norm(org, to_entrez = nil)
    require 'rbbt/ner/rnorm'
    if to_entrez.nil?
      to_entrez = id_index(org, :native => 'Entrez Gene ID', :other => [supported_ids(org).first])
    end
    
    token_file = File.join(Rbbt.datadir, 'norm','config',org.to_s + '.config')
    if !File.exists? token_file
      token_file = nil
    end

    Normalizer.new(File.join(Rbbt.datadir,"organisms/#{ org }/lexicon"), :to_entrez => to_entrez, :file => token_file, :max_candidates => 20)
  end

  # Returns a hash with the names associated with each gene id. The ids are
  # in Rbbt native format for that organism.
  def self.lexicon(org, options = {})
    options = {:sep => "\t|\\|", :flatten => true}.merge(options)
    Open.to_hash(File.join(Rbbt.datadir,"organisms/#{ org }/lexicon"),options)
  end

  # Returns a hash with the list of go terms for each gene id. Gene ids are in
  # Rbbt native format for that organism.
  def self.goterms(org)
    Open.to_hash(File.join(Rbbt.datadir,"organisms/#{ org }/gene.go"), :flatten => true)
  end

  # Return list of PubMed ids associated to the organism. Determined using a
  # PubMed query with the name of the organism
  def self.literature(org)
    Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/all.pmid")).scan(/\d+/)
  end

  # Return hash that associates genes to a list of PubMed ids.
  def self.gene_literature(org)
    Open.to_hash(File.join(Rbbt.datadir,"organisms/#{ org }/gene.pmid"), :flatten => true)
  end

  # Return hash that associates genes to a list of PubMed ids. Includes only
  # those found to support GO term associations.
  def self.gene_literature_go(org)
    Open.to_hash(File.join(Rbbt.datadir,"organisms/#{ org }/gene_go.pmid"), :flatten => true)
  end

  # Returns a list with the names of the id formats supported for an organism.
  # If examples are produced, the list is of [format, example] pairs.
  # 
  # *Options:*
  #
  # *examples:* Include example ids for each format
  def self.supported_ids(org, options = {})
    formats  = []
    examples = [] if options[:examples]
    i= 0
    Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/identifiers")).each_line{|l|
      if i == 0
        i += 1
        next unless l=~/^\s*#/
          formats  = Open.fields(l.sub(/^[\s#]+/,'')).collect{|n| n.strip}
        return formats unless examples
        next
      end

      if Open.fields(l).select{|name| name && name =~ /\w/}.length > examples.length
        examples = Open.fields(l).collect{|name| name.split(/\|/).first}
      end
      i += 1
    }

    formats.zip(examples)
  end

  # Creates a hash where each possible id is associated with the names of the
  # formats (its potentially possible for different formats to have the same
  # id). This is used in the guessIdFormat method. 
  def self.id_formats(org) 
    id_types = {} 
    formats = supported_ids(org)

    text = Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/identifiers"))
    
    if text.respond_to? :collect
      lines = text.collect
    else
      lines = text.lines
    end

    lines.each{|l|
      ids_per_type = Open.fields(l)
      formats.zip(ids_per_type).each{|p|
        format = p[0]
        p[1] ||= ""
        ids = p[1].split(/\|/)
        ids.each{|id|
          next if id.nil? || id == ""
          id_types[id.downcase] ||= []
          id_types[id.downcase] << format unless id_types[id.downcase].include? format
        }
      }
    }

    return id_types
  end

  def self.guessIdFormat(formats, query)
    query = query.compact.collect{|gene| gene.downcase}.uniq
    if String === formats
      formats = id_formats(formats)
    end

    return nil if formats.values.empty?
    values = formats.values_at(*query)
    return nil if values.empty?
    
    format_count = {}
    values.compact.collect{|types| types.uniq}.flatten.each{|f| 
      format_count[f] ||= 0
      format_count[f] += 1
    }
    
    return nil if format_count.values.empty?
    format_count.select{|k,v| v > (query.length / 10)}.sort{|a,b| b[1] <=> a[1]}.first
  end

  def self.id_position(supported_ids, id_name, options = {})
    pos = 0
    supported_ids.each_with_index{|id, i| 
      if id.strip == id_name.strip || !options[:case_sensitive] && id.strip.downcase == id_name.strip.downcase
        pos = i; 
      end
    }
    pos
  end

  def self.id_index(org, options = {})
    native = options[:native]
    other  = options[:other]
    options[:case_sensitive] = false if options[:case_sensitive].nil?

    if native.nil? and other.nil?
      Index.index(File.join(Rbbt.datadir,"organisms/#{ org }/identifiers"), options)
    else
      supported = Organism.supported_ids(org)

      first = nil
      if native
        first = id_position(supported,native,options)
      else
        first = 0
      end

      rest = nil
      if other
        rest = other.collect{|name| id_position(supported,name, options)}
      else
        rest = (0..supported.length - 1).to_a - [first]
      end

      options[:native] = first
      options[:extra] = rest
      options[:sep] = "\t"
      index = Index.index(File.join(Rbbt.datadir,"organisms/#{ org }/identifiers"), options)

      index
    end
  end

end

