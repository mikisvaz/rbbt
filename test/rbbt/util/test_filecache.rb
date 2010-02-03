require File.dirname(__FILE__) + '/../../test_helper'
require 'rbbt'
require 'rbbt/util/filecache'
require 'test/unit'

class TestFileCache < Test::Unit::TestCase

  def setup
    @cachedir = Rbbt.cachedir
  end
  
  def test_escape
    path = '/etc/password'
    assert_equal('_SLASH_etc_SLASH_password',FileCache.clean_path(path))
  end

  def test_path
    assert_equal(File.expand_path(FileCache.path('123456789.xml')), File.expand_path(File.join(@cachedir, '/5/6/7/8/9/123456789.xml')))
    assert_equal(File.expand_path(FileCache.path('12.xml')), File.expand_path(File.join(@cachedir, '/1/2/12.xml')))

    assert_raise(FileCache::BadPathError){FileCache.path('/etc/passwd')}
  end

  def test_add_read
    filename = 'test_file_cache.txt'
    content  = 'hello'

    FileCache.del_file(filename)
    FileCache.add_file(filename, content)
    assert_raise(FileCache::FileExistsError){FileCache.add_file(filename,'')}
    assert_nothing_raised{FileCache.add_file(filename,'',:force => true)}
    FileCache.del_file(filename)
    
  end


end
