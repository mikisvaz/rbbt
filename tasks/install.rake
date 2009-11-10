require 'rbbt'

$datadir = Rbbt.datadir
$scriptdir = File.join(Rbbt.rootdir, '/install_scripts')


task 'abner' do
  directory = "#{$datadir}/third_party/abner/"
  if !File.exists?(File.join(directory, 'abner.jar')) || $force
    FileUtils.mkdir_p directory
    `cd #{directory};rm -Rf *; #{$scriptdir}/get_abner.sh;cd -`
  end
end

task 'banner' do
  directory = "#{$datadir}/third_party/banner/"
  if !File.exists?(File.join(directory, 'banner.jar')) || $force 
    FileUtils.mkdir_p directory
    `cd #{directory};rm -Rf *; #{$scriptdir}/get_banner.sh;cd -`
  end
end

task 'crf++' do
  directory = "#{$datadir}/third_party/crf++/"
  if !File.exists?(File.join(directory, 'ruby/CRFPP.so')) || $force
    FileUtils.mkdir_p directory
    `cd #{directory};rm -Rf *; #{$scriptdir}/get_crf++.sh;cd -`
  end
end



task 'wordlists' do
  FileUtils.cp_r File.join($scriptdir, 'wordlists/'), $datadir
end

task 'polysearch' do
  directory = "#{$datadir}/dbs/polysearch/"
  if !File.exists?(File.join(directory,'disease.txt')) || $force
    FileUtils.mkdir_p directory
    `cd #{directory}/; rm * -Rf; #{$scriptdir}/get_polysearch.sh;cd -`
  end
end


task '3party' => %w(abner banner crf++)

task 'entrez' do
  directory = "#{$datadir}/dbs/entrez/"
  if !File.exists?(File.join(directory,'gene_info')) || $force
    FileUtils.mkdir_p directory
    `cd #{directory}/; rm * -Rf; #{$scriptdir}/get_entrez.sh;cd -`
  end
end

task 'go' do
  directory = "#{$datadir}/dbs/go/"
  if !File.exists?(File.join(directory,'gene_ontology.obo')) || $force
    FileUtils.mkdir_p directory
    `cd #{directory}/; rm * -Rf; #{$scriptdir}/get_go.sh;cd -`
  end
end

task 'biocreative' do
  directory = "#{$datadir}/biocreative/"
  if !File.exists?(File.join(directory, 'BC2GN')) || $force
    FileUtils.mkdir_p directory
    `cd #{directory};rm -Rf *; #{$scriptdir}/get_biocreative.sh;cd -`
  end
end


task 'datasets' => %w(entrez biocreative)

task 'organisms' do
  directory = "#{$datadir}/organisms"
  FileUtils.mkdir_p directory
  %w(Rakefile rake-include.rb).each{|f|
    FileUtils.cp_r File.join($scriptdir, "organisms/#{ f }"), directory
  }
  Dir.glob(File.join($scriptdir, "organisms/*.Rakefile")).each{|f|
    org = File.basename(f).sub(/.Rakefile/,'')
    if !File.exists?(File.join(directory, org))
      FileUtils.mkdir_p File.join(directory, org)
    end
    FileUtils.cp f , File.join(directory, "#{ org }/Rakefile")
  }
  `cd #{directory}; rake names`
end

task 'ner' do
  directory = "#{$datadir}/ner"
  FileUtils.mkdir_p directory
  %w(Rakefile config).each{|f|
    FileUtils.cp_r File.join($scriptdir, "ner/#{ f }"), directory 
  }
  
  %w(data model results).each{|d|
    FileUtils.mkdir_p File.join(directory, d)
  }
end

task 'norm' do
  directory = "#{$datadir}/norm"
  FileUtils.mkdir_p directory
  %w(Rakefile config functions.sh).each{|f|
    FileUtils.cp_r File.join($scriptdir, "norm/#{ f }"), directory 
  }
 %w(results models).each{|d|
  FileUtils.mkdir_p File.join(directory, d)
  }
end

task 'classifier' do
  directory = "#{$datadir}/classifier"
  FileUtils.mkdir_p directory
  %w(Rakefile R).each{|f|
    FileUtils.cp_r File.join($scriptdir, "classifier/#{ f }"), directory
  }
  %w(data model results).each{|d|
    FileUtils.mkdir_p File.join(directory, d)
  }
end

