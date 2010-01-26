require 'rbbt'
require 'rbbt/util/tmpfile'


# Provides with a few helper functions to read and write files, as well # as
# for accessing remote files. It supports caching the files.
module Open

  def self.fields(line, sep = "\t")
    chunks = line.chomp.split(/(#{sep})/).select{|c| c !~ /^#{sep}$/ }
    if line =~ /#{sep}$/
      chunks << ""
    end
    chunks
  end

  class DirectoryNotFoundError < StandardError; end
  class OpenURLError < StandardError; end

  private 

  @@remote_cachedir =  File.join(Rbbt.cachedir, 'open-remote/')
  FileUtils.mkdir @@remote_cachedir unless File.exist? @@remote_cachedir

  # If no data is specified and the url is found in the cache the saved
  # contents are returned, if not found, the url is opened and the contents of
  # that are returned. If +data+ is specified then it is saved in the
  # cache under +url+. To match +url+ in the cache a MD5 digest is used.
  # The location of the cache directory is bu default
  # File.join(Rbbt.cachedir, 'open-remote/').
  def self.cache(url, data = nil)
    require 'digest/md5'
    digest = Digest::MD5.hexdigest(url)

    if data
      Open.write(File.join(@@remote_cachedir, digest), data)
      return nil
    else
      if File.exist? File.join(@@remote_cachedir, digest)
        return File.open(File.join(@@remote_cachedir, digest)){|file| file.read }
      else
        return nil
      end
    end
  end

  # Checks if +url+ is a remote file.
  def self.remote(url)
    url =~ /^(?:http|ssh|https|ftp):\/\//
  end


  # Checks if +url+ is a gzip file.
  def self.gziped(url)
    if remote(url)
      return url =~ /\.gz$/ || url =~ /\.gz\?.*$/
    else
      return url =~ /\.gz$/ 
    end
  end


  @@last_time = Time.now   
  def self.wait(lag = 0)
    time = Time.now   

    if time < @@last_time + lag
      sleep @@last_time + lag - time
    end

    @@last_time = Time.now   
  end

  public
  # Reads the file specified by url. If the url es local it just opens
  # the file, if it is remote if checks the cache first. In any case, it
  # unzips gzip files automatically.
  #
  # Options: 
  # * :quiet    => Do not print the progress of downloads
  # * :nocache  => do not use the cache.
  # * :nice     => secconds to wait between online queries
  #
  def self.read(url, options = {})

    case
    when remote(url)
      if !options[:nocache] && data = cache(url)
        return data
      end

      wait(options[:nice]) if options[:nice]
      tmp = TmpFile.tmp_file("open-")
      `wget -O #{tmp} '#{url}' #{options[:quiet] ? '-q' : '' }`

      if $?.success?
        if gziped(url)
        `mv #{tmp} #{tmp}.gz; gunzip #{tmp}`
        end

        cache(url, File.open(tmp){|file| file.read}) unless options[:nocache]

        data = File.open(tmp){|file| file.read}
        FileUtils.rm tmp
        return data
      else
        raise OpenURLError, "Error reading remote url: #{ url }"
      end
    
    when IO === url
      url.read
    else
      return  File.open(url){|file| file.read}
    end

  end

  # Writes the contents on the path specified by filename
  #
  # Options: 
  # * :force => Create directories if missing.
  def self.write(filename, content, options = {})
    if !File.exist? File.dirname(filename) 
      if options[:force] 
        FileUtils.makedirs(File.dirname(filename))
      else
        raise Open::DirectoryNotFoundError, "Directory #{File.dirname(filename)} was not found"
      end
    end

    File.open(filename,'w'){|f|
      f.write content
    }

    nil
  end

  # Writes the contents on the path specified by filename. If the file
  # is present it appends the contents.
  #
  # Options: 
  # * :force => Create directories if missing.
  def self.append(filename, content, options ={})
    if !File.exist? File.dirname(filename) 
      if options[:force] 
        FileUtils.makedirs(File.dirname(filename))
      else
        raise Open::DirectoryNotFoundError, "Directory #{File.dirname(filename)} was not found"
      end
    end

    f = File.open(filename,'a')
    f.write content
    f.close

    nil
  end



  # Reads a file with rows with elementes separated by a given pattern
  # and builds a hash with it. The keys of the hash are the elements in
  # the :native positions, by default the first (0). The value for each
  # key is an array with one position for each of the rest possible
  # positions specified in :extra, by default all but the :native. Since
  # the native key may be repeated, each of the positions of the values
  # is in itself an array. There are a number of options to change this
  # behaviour.
  #
  # Options:
  # * :native => position of the elements that will constitute the keys. By default 0.
  # * :extra => positions of the rest of elements. By default all but :native. It can be an array of positions or a single position.
  # * :sep =>  pattern to use in splitting the lines into elements, by default "\t"
  # * :flatten => flatten the array of arrays that hold the values for each key into a simple array.
  # * :single => for each key select only the first of the values, instead of the complete array.
  # * :fix  => A Proc that is called to pre-process the line
  # * :exclude => A Proc that is called to check if the line must be excluded from the process.
  def self.to_hash(input, options = {})
    native  = options[:native]  || 0
    extra   = options[:extra]
    exclude = options[:exclude]
    fix     = options[:fix]
    sep     = options[:sep]     || "\t"
    single  = options[:single]  
    single  = false if single.nil?
    flatten = options[:flatten] || single
    flatten = single if flatten.nil?

    extra = [extra] if extra && ! extra.is_a?( Array)

    if StringIO === input
      content = input
    else
      content = Open.read(input)
    end

    data = {}
    content.each_line{|l|
      l = fix.call(l) if fix
      next if exclude and exclude.call(l)

      row_fields = self.fields(l, sep)
      id = row_fields[native]
      next if id.nil? || id == ""

      data[id] ||= []
      if extra
        fields = extra
      else
        fields = (0..(row_fields.length - 1)).to_a - [native] 
      end
      fields.each_with_index{|pos,i|
        data[id][i] ||= []
        data[id][i] << row_fields[pos]
      }
    }

    if flatten
      data.each{|key, values| 
        if values 
          values.flatten!
          values.collect!{|v| 
            if v != ""
              v 
            else 
              nil 
            end
          }
          values.compact! 
        else 
          nil 
        end
      } 
    end

    data = Hash[*(data.collect{|key,values| [key, values.first]}).flatten] if single
    
    data
  end

end
