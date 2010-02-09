require 'simplews/rake'
require 'rbbt/sources/organism'

class GeneDiseasesWS < SimpleWS::Jobs

  # Load the index before hand to share it between tasks
  @index = Organism.id_index('Hsa')
  def self.translate(genes)
    @index.values_at(*genes).compact.flatten.uniq
  end

  task :diseases, %w(genes), {:genes => :array}, ['diseases/{JOB}'] do |genes|
    
    # Translate the genes manually with the GeneDiseasesWS function and save it to the
    # entrez directory
    step(:translate, "Translating genes to Entrez gene ids")
    entrez = GeneDiseasesWS::translate(genes.uniq)
    write('entrez/' + job_name, entrez.join("\n"))

    # Instruct rake to continue producing the file
    rake
    info(:pmids => Open.read(path('pmids/' + job_name)).split(/\n/).length)
  end

end

if __FILE__ == $0

  # Create directories for intermediate results
  %w(entrez pmids metadoc diseases).collect{|dir| File.join('work', dir)}.each{|dir|
    FileUtils.mkdir_p dir unless File.exist? dir
  }

  # Launch the web service
  puts "Starting GeneDiseasesWS"
  GeneDiseasesWS.new('GeneDiseasesWS', 'Find diseases associated to a list of genes', 'localhost', 8081, 'work').start
end

