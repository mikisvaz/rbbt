require 'mechanize'


module GoogleScholar
  def self.user_agent
    @@a ||= Mechanize.new
  end

  def self.citation_link(title)
    citation_link = nil

    # Get citation page
    user_agent.get("http://scholar.google.es/scholar?q='#{ title }'&hl=es&lr=&lr=") do |page|
      article = page.search('div[@class=gs_r]').first
      return nil if article.nil?

      return article.search('a').select{|link| link['href'] =~ /scholar\?cites/ && link.inner_html =~ /\d+$/ }.first
    end
  end

  def self.full_text_url(title)
    full_text_link = nil

    # Get page
    user_agent.get("http://scholar.google.es/scholar?q='#{ title }'&hl=es&lr=&lr=") do |page|
      article = page.search('div[@class=gs_r]').first
      return nil if article.nil?

      link =  article.search('a').select{ |link| 
        link['href'] =~ /\.pdf$/ || link['href'] =~ /type=pdf/
      }.first

      return nil if link.nil?

      return link['href']
    end
  end


  def self.number_cites(title)

    link = citation_link title
    return 0 if link.nil?

    link.inner_html =~ /(\d+)$/ 

    return $1.to_i
  end

end


#def get_citers(title)
#  puts title
#  citation_link = nil
#
#  # Get citation page
#  $a.get("http://scholar.google.es/scholar?q='#{ title }'&hl=es&lr=&lr=") do |page|
#    citation_link = page.search('div[@class=gs_r]').first.search('a').select{|link| link['href'] =~ /scholar\?cites/ && link.inner_html =~ /\d+$/ }.first
#  end
#
#  return [] if citation_link.nil?
#
#  # Parse citations
#  
#  citers = []
#  $a.get("http://scholar.google.es" + citation_link['href']) do |page|
#    citers = page.search('div[@class=gs_r]').collect do |entry| 
#      entry.search('h3').first.search('a').first.inner_html
#    end
#  end
#
#  return citers
#end
