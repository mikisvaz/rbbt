require 'rbbt'
require 'rbbt/util/open'


# Offers methods to help deal with the files distributed for the BioCreative
# competition related to Gene Mention and Normalization.
module Biocreative

  # Read the files regarding the dataset and return a hash with the entry codes
  # as keys and as values a hash with :text and the :mentions for that entry
  def self.BC2GM(dataset)

    data = {}

    Open.read(File.join(Rbbt.datadir,"biocreative/BC2GM/#{dataset}/#{dataset}.in")).each{|l|
      code, text = l.chomp.match(/(.*?) (.*)/).values_at(1,2)
      data[code] ={ :text => text }
    }

    Open.read(File.join(Rbbt.datadir,"biocreative/BC2GM/#{dataset}/GENE.eval")).each{|l|
      code, pos, mention = l.chomp.split(/\|/)
      data[code] ||= {}
      data[code][:mentions] ||= []
      data[code][:mentions].push(mention)
    }


    data

  end

  # Given a string of text and a string with a mention, return positions for
  # that mention in the format used in the evaluation. 
  def self.position(text, mention)

    re = mention.gsub(/\W+/,' ')
    re = Regexp.quote(re)
    re = re.gsub(/\\ /,'\W*')
    re = '\(?' + re if mention =~ /\)/
    re = re + '\)?' if mention =~ /\(/
    re = "'?" + re + "'?" if mention =~ /'/

    positions = []

    offset = 0
    while text.match(/(.*?)(#{re})(.*)/s)
      pre, mention, post = text.match(/(.*?)(#{re})(.*)/s).values_at(1,2,3)

      start                     = offset  + pre.gsub(/\s/,'').length
      last                      = offset  + pre.gsub(/\s/,'').length + mention.gsub(/\s/,'').length - 1

      positions << [start, last]

      offset                    = last + 1
      text                      = post
      end

    return positions
  end

  # Run the evaluation perl script
  def self.BC2GM_eval(results, dataset, outfile)


    cmd = "/usr/bin/perl #{File.join(Rbbt.datadir, 'biocreative/BC2GM/alt_eval.perl')}\
                         -gene #{File.join(Rbbt.datadir, "biocreative/BC2GM/#{dataset}/GENE.eval")}\
                         -altgene #{File.join(Rbbt.datadir, "biocreative/BC2GM/#{dataset}/ALTGENE.eval")}\
                          #{results} > #{outfile}"
    system cmd

  end

end


