require File.dirname(__FILE__) + '/../../test_helper'
require 'rbbt/util/tmpfile'
require 'test/unit'

class TestTmpFile < Test::Unit::TestCase

  def test_tmp_file
    assert(TmpFile.tmp_file("test") =~ /tmp\/test\d+$/)
  end

  def test_do_tmp_file
    content = "Hello World!"
    TmpFile.with_file(content) do |file|
      assert_equal content, File.open(file).read
    end
  end


end


