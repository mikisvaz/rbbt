require 'fileutils'
require 'rbbt'

# Provides caching functionality for files downloaded from the internet
module FileCache

  class BadPathError    < StandardError; end
  class FileExistsError < StandardError; end

  private 

  # Remove slash characters from filename.
  def self.clean_path(filename)
    filename.gsub(/\//,'_SLASH_')
  end

  # Check that the file name is safe and is in the correct format
  def self.sanity_check(filename)
    if filename =~ /\//
      raise FileCache::BadPathError, "Character / not allowed in name: #{ filename }"
    end
    if filename !~ /.+\..+/
      raise FileCache::BadPathError, "Filename must have name and extension: name.ext"
    end
  end

  public 

  # Find the path that a particular file would have in the cache
  def self.path(filename)
    sanity_check(filename)

    name, extension = filename.match(/(.+)\.(.+)/).values_at(1,2)
    dirs = name.scan(/./).reverse.values_at(0,1,2,3,4).reverse.compact.join('/')
                                            
    return File.join(File.join(Rbbt.cachedir,dirs),filename)
  end

  # Add a file in the cache. Raise exception if exists, unless force is
  # used.
  def self.add_file(filename, content, options = {})
    sanity_check(filename)

    path = path(filename)
    FileUtils.makedirs(File.dirname(path), :mode => 0777)

    if File.exist?(path) and ! (options[:force] || options['force'])
      raise FileCache::FileExistsError, "File #{filename} already in cache"
    end

    File.open(path,'w'){|f|
      f.write(content)
    }
    FileUtils.chmod 0666, path

    nil
  end

  # Removes the file from cache
  def self.del_file(filename)
    sanity_check(filename)

    path = path(filename)

    if File.exist? path
      FileUtils.rm path
    end

    nil
  end

end
