
require 'rbbt'
require 'rbbt/util/open'
require 'rbbt/util/tmpfile'
require 'rbbt/util/filecache'
require 'rbbt/bow/bow.rb'
require 'set'


# This module is used to parse and extract information from the
# gene_info file at Entrez Gene, as well as from the gene2pubmed file.
# Both need to be downloaded and accesible for Rbbt, which is done as
# part of a normal installation.
module Entrez

  class NoFileError < StandardError; end

  # Given a taxonomy, or set of taxonomies, it returns an inverse hash,
  # where each key is the entrez id of a gene, and the value is an array
  # of possible synonyms in other databases. Is mostly used to translate
  # entrez ids to the native database id of the organism. The parameter
  # +native+ specifies the position of the key containing synonym, the
  # fifth by default, +fix+ and +check+ are Procs used, if present, to
  # pre-process lines and to check if they should be processed.
  def self.entrez2native(taxs, native = nil, fix = nil, check = nil)

    raise NoFileError, "Install the Entrez gene_info file" unless File.exists? File.join(Rbbt.datadir, 'dbs/entrez/gene_info')

    native ||= 5

    taxs = [taxs] unless taxs.is_a?(Array)
    taxs = taxs.collect{|t| t.to_s}

    lexicon = {}
    tmp = TmpFile.tmp_file("entrez-")
    system "cat '#{File.join(Rbbt.datadir, 'dbs/entrez/gene_info')}' |grep '^\\(#{taxs.join('\\|')}\\)[[:space:]]' > #{tmp}"
    File.open(tmp).each{|l| 
      parts = l.chomp.split(/\t/)
      next if parts[native] == '-'
      entrez = parts[1]
      parts[native].split(/\|/).each{|id|
        id = fix.call(id) if fix
        next if check && !check.call(id)

        lexicon[entrez] ||= []
        lexicon[entrez] << id
      }
    }
    FileUtils.rm tmp

    lexicon
  end

  # For a given taxonomy, or set of taxonomies, it returns a hash with
  # genes as keys and arrays of related PubMed ids as values, as
  # extracted from the gene2pubmed file from Entrez Gene.
  def self.entrez2pubmed(taxs)
    raise NoFileError, "Install the Entrez gene2pubmed file" unless File.exists? File.join(Rbbt.datadir, 'dbs/entrez/gene2pubmed')

    taxs = [taxs] unless taxs.is_a?(Array)
    taxs = taxs.collect{|t| t.to_s}

    data = {}
    tmp = TmpFile.tmp_file("entrez-")
    system "cat '#{File.join(Rbbt.datadir, 'dbs/entrez/gene2pubmed')}' |grep '^\\(#{taxs.join('\\|')}\\)[[:space:]]' > #{tmp}"
 
    data = Open.to_hash(tmp, :native => 1, :extra => 2).each{|code, value_lists| value_lists.flatten!}

    FileUtils.rm tmp

    data
  end



  # This class parses an xml containing the information for a particular
  # gene as served by Entrez Gene, and hold some of its information.
  class Gene
    attr_reader :organism, :symbol, :description, :aka, :protnames, :summary, :comentaries

    def initialize(xml)
      return if xml.nil?

      @organism    = xml.scan(/<Org-ref_taxname>(.*)<\/Org-ref_taxname>/s)
      @symbol      = xml.scan(/<Gene-ref_locus>(.*)<\/Gene-ref_locus>/s)
      @description = xml.scan(/<Gene-ref_desc>(.*)<\/Gene-ref_desc>/s)
      @aka         = xml.scan(/<Gene-ref_syn_E>(.*)<\Gene-ref_syn_E>/s)
      @protnames   = xml.scan(/<Prot-ref_name_E>(.*)<\/Prot-ref_name_E>/s)
      @summary     = xml.scan(/<Entrezgene_summary>(.*)<\/Entrezgene_summary>/s)
      @comentaries = xml.scan(/<Gene-commentary_text>(.*)<\/Gene-commentary_text>/s)


    end

    # Joins the text from symbol, description, aka, protnames, and
    # summary
    def text
      #[@organism, @symbol, @description, @aka,  @protnames, @summary,@comentaries.join(". ")].join(". ") 
      [@symbol, @description, @aka,  @protnames, @summary].flatten.join(". ") 
    end
  end

  private 

  @@last = Time.now
  @@entrez_lag = 1
  def self.get_online(geneids)

    geneids_list = ( geneids.is_a?(Array) ? geneids.join(',') : geneids.to_s )
    url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&retmode=xml&id=#{geneids_list}" 

    diff = Time.now - @@last
    sleep @@entrez_lag - diff unless diff > @@entrez_lag

    xml = Open.read(url, :quiet => true, :nocache => true)

    @@last = Time.now

    genes = xml.scan(/(<Entrezgene>.*?<\/Entrezgene>)/sm).flatten

    if geneids.is_a? Array
      list = {}
      genes.each_with_index{|gene,i|
        #geneid  = gene.scan(/<Gene-track_geneid>(.*?)<\/Gene-track_geneid>/).flatten.first
        geneid = geneids[i]
        list[geneid ] = gene
      }
      return list
    else
      return genes.first
    end

  end

  public

  # Build a file name for a gene based on the id. Prefix the id by 'gene-',
  # substitute the slashes with '_SLASH_', and add a '.xml' extension.
  def self.gene_filename(id)
    FileCache.clean_path('gene-' + id.to_s + '.xml')
  end

  # Returns a Gene object for the given Entrez Gene id. If an array of
  # ids is given instead, a hash is returned. This method uses the
  # caching facilities from Rbbt.
  def self.get_gene(geneid)

    return nil if geneid.nil?

    if Array === geneid
      missing = []
      list = {}

      geneid.each{|p|
        next if p.nil?
        filename = gene_filename p    
        if File.exists? FileCache.path(filename)
          list[p] = Gene.new(Open.read(FileCache.path(filename)))
        else
          missing << p
        end
      }

      return list unless missing.any?
      genes = get_online(missing)

      genes.each{|p, xml|
        filename = gene_filename p    
        FileCache.add_file(filename,xml) unless File.exist? FileCache.path(filename)
        list[p] =  Gene.new(xml)
      }

      return list

    else
      filename = gene_filename geneid    

      if File.exists? FileCache.path(filename)
        return Gene.new(Open.read(FileCache.path(filename)))
      else
        xml = get_online(geneid)
        FileCache.add_file(filename,xml)

        return Gene.new(xml)
      end
    end
  end

  # Counts the words in common between a chunk of text and the text
  # found in Entrez Gene for that particular gene. The +gene+ may be a
  # gene identifier or a Gene class instance.
  def self.gene_text_similarity(gene, text)
    case
    when Entrez::Gene === gene
      gene_text = gene.text
    when String === gene || Fixnum === gene
      gene_text =  get_gene(gene).text
    else
      return 0
    end


    gene_words = gene_text.words.to_set
    text_words = text.words.to_set

    return 0 if gene_words.empty? || text_words.empty?

    common = gene_words.intersection(text_words)
    common.length / (gene_words.length + text_words.length).to_f
  end
end
