# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rbbt"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Miguel Vazquez"]
  s.date = "2013-06-10"
  s.description = "Meta package for a gem that requires the basic Rbbt packages"
  s.email = "miguel.vazquez@cnio.es"
  s.homepage = "http://github.com/mikisvaz/rbbt"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Ruby bioinformatics toolbox. Meta package"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rbbt-util>, [">= 0"])
      s.add_runtime_dependency(%q<rbbt-rest>, [">= 0"])
      s.add_runtime_dependency(%q<rbbt-entities>, [">= 0"])
    else
      s.add_dependency(%q<rbbt-util>, [">= 0"])
      s.add_dependency(%q<rbbt-rest>, [">= 0"])
      s.add_dependency(%q<rbbt-entities>, [">= 0"])
    end
  else
    s.add_dependency(%q<rbbt-util>, [">= 0"])
    s.add_dependency(%q<rbbt-rest>, [">= 0"])
    s.add_dependency(%q<rbbt-entities>, [">= 0"])
  end
end

