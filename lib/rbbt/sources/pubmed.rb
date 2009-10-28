require 'rbbt/util/filecache'
require 'rbbt/util/open'
require 'rbbt'

# This module offers an interface with PubMed, to perform queries, and
# retrieve simple information from articles. It uses the caching
# services of Rbbt.
module PubMed

  private
  @@last = Time.now
  @@pubmed_lag = 1
  def self.get_online(pmids)

    pmid_list = ( pmids.is_a?(Array) ? pmids.join(',') : pmids.to_s )
    url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=#{pmid_list}" 

    diff = Time.now - @@last
    sleep @@pubmed_lag - diff unless diff > @@pubmed_lag

    xml = Open.read(url, :quiet => true, :nocache => true)
    
    @@last = Time.now

    articles = xml.scan(/(<PubmedArticle>.*?<\/PubmedArticle>)/sm).flatten

    if pmids.is_a? Array
      list = {}
      articles.each{|article|
        pmid = article.scan(/<PMID>(.*?)<\/PMID>/).flatten.first
        list[pmid] = article
      }
      return list
    else
      return articles.first
    end

  end

  public

  # Processes the xml with an articles as served by MedLine and extracts
  # the abstract, title and journal information
  class Article
    attr_reader :title, :abstract, :journal
    def initialize(xml)
      xml ||= ""
      @abstract = $1 if xml.match(/<AbstractText>(.*)<\/AbstractText>/sm)
      @title    = $1 if xml.match(/<ArticleTitle>(.*)<\/ArticleTitle>/sm)
      @journal  = $1 if xml.match(/<Title>(.*)<\/Title>/sm)
    end

    # Join the text from title and abstract
    def text
      [@title, @abstract].join("\n")
    end
  end

  # Returns the Article object containing the information for the PubMed
  # ID specified as an argument. If +pmid+ is an array instead of a single
  # identifier it returns an hash with the Article object for each id.
  # It uses the Rbbt cache to save the articles xml.
  def self.get_article(pmid)

    if pmid.is_a? Array
      missing = []
      list = {}

      pmid.each{|p|
        filename = p.to_s + '.xml'
        if File.exists? FileCache.path(filename)
          list[p] = Article.new(Open.read(FileCache.path(filename)))
        else
          missing << p
        end
      }

      return list unless missing.any?
      articles = get_online(missing)

      articles.each{|p, xml|
        filename = p + '.xml'
        FileCache.add_file(filename,xml, :force => true)
        list[p] =  Article.new(xml)
      }

      return list

    else
      filename = pmid.to_s + '.xml'

      if File.exists? FileCache.path(filename)
        return Article.new(Open.read(FileCache.path(filename)))
      else
        xml = get_online(pmid)
        FileCache.add_file(filename,xml)

        return Article.new(xml)
      end
    end
  end

  # Performs the specified query and returns an array with the PubMed
  # Ids returned. +retmax+ can be used to limit the number of ids
  # returned, if is not specified 30000 is used.
  def self.query(query, retmax=nil)
    retmax ||= 30000

    Open.read("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?retmax=#{retmax}&db=pubmed&term=#{query}",:quiet => true, :nocache => true).scan(/<Id>(\d+)<\/Id>/).flatten
  end
end
