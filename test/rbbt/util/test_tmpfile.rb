require 'rbbt/util/tmpfile'
require 'test/unit'

class TestTmpFile < Test::Unit::TestCase

  def test_tmp_file
    assert(TmpFile.tmp_file("test") =~ /tmp\/test\d+$/)
  end


end


