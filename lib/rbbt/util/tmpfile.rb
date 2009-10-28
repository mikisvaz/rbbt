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
end
