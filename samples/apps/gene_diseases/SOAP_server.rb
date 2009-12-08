require 'simplews/rake'

class GeneDiseasesWS < SimpleWS::Jobs

  # Gene list must be in Entrez Gene id format
  task :diseases, %w(list), {:list => :array}, ['diseases/{JOB}'] do |list|
    
    # Add some status messages for different rake subtasks. Task defined as
    # rules cannot be described using the desc method in rake.
    add_message('pmids', :pmids, "Listing article pmids for genes in the list")
    add_message('metadoc', :metadoc, "Joining article abstracts in meta-document")
    add_message('diseases', :disease, "Finding disease terms in meta-document")


    # Prepare input data for the pipeline using a global variable
    $genes = list

    # Instruct rake to produce the file
    rake
  end

end

if __FILE__ == $0

  # Create directories for intemediate results
  %w(pmids metadocs diseases).collect{|dir| File.join('work', dir)}.each{|dir|
    FileUtils.mkdir_p dir unless File.exist? dir
  }

  # Launch the web service
  GeneDiseasesWS.new('GeneDiseasesWS', 'Find diseases associated to a list of genes', 'localhost', 8081, 'work').start
end

