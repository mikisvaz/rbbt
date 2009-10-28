$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'fileutils'
require 'yaml'


# This module implements a number of utilities aimed at performing Text
# Mining of BioMedical data. I includes the following:
#
# * Multi-purpose Named Entity Recognition and Normalization. And training data for
#   Gene Mention from the BioCreative competition.
# * Document Classification
# * Interfaces to Gene Ontology, Entrez Gene, BioMart and PubMed
# 
# There are a number of classes to help gather and integrate the
# information from all the sources. It is design to be very flexible,
# but with a sensible set of defaults. 
#
module Rbbt

  class NoConfig < Exception; end

  @@rootdir = File.dirname(File.dirname(__FILE__))

  @@datadir = @@cachedir = @@tmpdir = nil

  def self.load_config
    if File.exist?(File.join(@@rootdir, 'rbbt.config'))
      config = YAML.load_file(File.join(@@rootdir, 'rbbt.config'))
      if config.is_a? Hash
        @@datadir  = config['datadir'] if config['datadir'] 
        @@cachedir = config['cachedir'] if config['cachedir']
        @@tmpdir   = config['tmpdir'] if config['tmpdir']
      end
    end



    if File.exist?(File.join(ENV['HOME'], '.rbbt'))
      config = YAML.load_file(File.join(ENV['HOME'], '.rbbt') )
      if config.is_a? Hash
        @@datadir  = config['datadir'] if config['datadir'] 
        @@cachedir = config['cachedir'] if config['cachedir']
        @@tmpdir   = config['tmpdir'] if config['tmpdir']
      end
    end

    if @@datadir.nil?  || @@cachedir.nil? || @@tmpdir.nil?
      raise NoConfig, "rbbt not configured. Edit #{File.join(@@rootdir, 'rbbt.config')} or $HOME/.rbbt"
    end


    FileUtils.mkdir_p @@datadir  unless File.exist? @@datadir
    FileUtils.mkdir_p @@cachedir unless File.exist? @@cachedir
    FileUtils.mkdir_p @@tmpdir   unless File.exist? @@tmpdir



    # For some reason banner.jar must be loaded before abner.jar
    ENV['CLASSPATH'] ||= ""
    ENV['CLASSPATH'] += ":" + %w(banner abner).collect{|pkg| File.join(datadir, "third_party/#{pkg}/#{ pkg }.jar")}.join(":")
  end

  def self.rootdir
    @@rootdir
  end 


  def self.datadir
    @@datadir
  end 

  def self.cachedir
    @@cachedir
  end 
  
  def self.tmpdir
    @@tmpdir
  end 


  self.load_config
end


