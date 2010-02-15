require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rbbt"
    gem.summary = %Q{Bioinformatics and text mining toolbox}
    gem.description = %Q{This toolbox includes modules for text-mining, like Named Entity Recognition and Normalization and document
    classification, as well as data integration modules that interface with PubMed, Entrez Gene, BioMart.}
    gem.email = "miguel.vazquez@fdi.ucm.es"
    gem.homepage = "http://github.com/mikisvaz/rbbt"
    gem.authors = ["Miguel Vazquez"]
    gem.files = Dir['lib/**/*.rb','bin/rbbt_config','tasks/install.rake', 'install_scripts/**/*']
    gem.test_files = Dir['test/**/test_*.rb']

    gem.add_dependency('rake', ' >= 0.8.4')
    gem.add_dependency('simpleconsole')
    gem.add_dependency('stemmer')
    gem.add_dependency('progress-monitor')
    gem.add_dependency('simpleconsole')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rbbt #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
