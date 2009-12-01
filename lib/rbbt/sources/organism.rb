require 'rbbt'
require 'rbbt/util/open'
require 'rbbt/util/index'


module Organism

  class OrganismNotProcessedError < StandardError; end

  def self.all(installed = true)
    if installed
      Dir.glob(File.join(Rbbt.datadir,'/organisms/') + '/*/identifiers').collect{|f| File.basename(File.dirname(f))}
    else
      Dir.glob(File.join(Rbbt.datadir,'/organisms/') + '/*').select{|f| File.directory? f}.collect{|f| File.basename(f)}
    end
  end


  def self.name(org)
    raise OrganismNotProcessedError, "Missing 'name' file" if ! File.exists? File.join(Rbbt.datadir,"organisms/#{ org }/name")
    Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/name"))
  end

  NAME2ORG = {}
  Organism::all.each{|org|  
    name = Organism.name(org).strip.downcase
    NAME2ORG[name] = org
  }

  def self.name2org(name)  
    NAME2ORG[name.strip.downcase]
  end

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
      ids_per_type = l.chomp.split(/\t/)
      formats.zip(ids_per_type).each{|p|
        next if p[1].nil?
        format = p[0]
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

  # FIXME: The NER related stuff is harder to install, thats why we hide the
  # requires next to where they are needed, next to options
  
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

  def self.lexicon(org, options = {})
    options[:sep] = "\t|\\|" unless options[:sep]
    Open.to_hash(File.join(Rbbt.datadir,"organisms/#{ org }/lexicon"),options)
  end

  def self.goterms(org)
    goterms = {}
    Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/gene.go")).each_line{|l|
      gene, go = l.chomp.split(/\t/)
      goterms[gene.strip] ||= []
      goterms[gene.strip] << go.strip
    }
    goterms
  end

  def self.literature(org)
    Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/all.pmid")).scan(/\d+/)
  end

  def self.gene_literature(org)
    Open.to_hash(File.join(Rbbt.datadir,"organisms/#{ org }/gene.pmid"), :flatten => true)
  end

  def self.gene_literature_go(org)
    Open.to_hash(File.join(Rbbt.datadir,"organisms/#{ org }/gene_go.pmid"), :flatten => true)
  end

  def self.supported_ids(org, options = {})
    formats  = []
    examples = [] if options[:examples]
    i= 0
    Open.read(File.join(Rbbt.datadir,"organisms/#{ org }/identifiers")).each_line{|l|
      if i == 0
        i += 1
        next unless l=~/^\s*#/
          formats  = l.chomp.sub(/^[\s#]+/,'').split(/\t/).collect{|n| n.strip}
        return formats unless examples
        next
      end

      if l.chomp.split(/\t/).select{|name| name && name =~ /\w/}.length > examples.length
        examples = l.chomp.split(/\t/).collect{|name| name.split(/\|/).first}
      end
      i += 1
    }

    formats.zip(examples)
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

  def self.id_index(org, option = {})
    native = option[:native]
    other  = option[:other]
    option[:case_sensitive] = false if option[:case_sensitive].nil?

    if native.nil? and other.nil?
      Index.index(File.join(Rbbt.datadir,"organisms/#{ org }/identifiers"), option)
    else
      supported = Organism.supported_ids(org)

      first = nil
      if native
        first = id_position(supported,native,option)
      else
        first = 0
      end

      rest = nil
      if other
        rest = other.collect{|name| id_position(supported,name, option)}
      else
        rest = (0..supported.length - 1).to_a - [first]
      end

      option[:native] = first
      option[:extra] = rest
      index = Index.index(File.join(Rbbt.datadir,"organisms/#{ org }/identifiers"), option)

      index
    end
  end

end

