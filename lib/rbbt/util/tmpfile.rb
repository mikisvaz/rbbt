require 'fileutils'
require 'rbbt' 


module TmpFile

  # Creates a random file name, with the given suffix and a random number
  # up to +max+
  def self.random_name( s="",max=10000000)
    n = rand(max)
    s << n.to_s
    s
  end

  # Creates a random filename in the temporary directory
  def self.tmp_file(s = "",max=10000000)
    File.join(Rbbt.tmpdir,random_name(s,max))
  end

  def self.with_file(content = nil)
    tmpfile = tmp_file

    File.open(tmpfile, 'w') do |f| f.write content end if content != nil

    result = yield(tmpfile)

    FileUtils.rm tmpfile if File.exists? tmpfile

    result
  end

  class << self
    alias :new :tmp_file
  end
end
