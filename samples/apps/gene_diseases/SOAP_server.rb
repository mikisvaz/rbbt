require 'simplews/rake'

class GeneDiseasesWS < SimpleWS::Jobs

  task :diseases, %w(list), {:list => :array}, ['diseases/{JOB}'] do |list|
    
    # Prepare input data for the pipeline using a global variable
    $genes = list

    # Instruct rake to produce the file
    rake
  end

end

if __FILE__ == $0

  # Create directories for intemediate results
  %w(pmids metadoc diseases).collect{|dir| File.join('work', dir)}.each{|dir|
    FileUtils.mkdir_p dir unless File.exist? dir
  }

  # Launch the web service
  GeneDiseasesWS.new('GeneDiseasesWS', 'Find diseases associated to a list of genes', 'localhost', 8081, 'work').start
end

