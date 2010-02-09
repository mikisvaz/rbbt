require File.dirname(__FILE__) + '/../../test_helper'

require 'rbbt/sources/go'
require 'test/unit'

class TestGo < Test::Unit::TestCase

  def test_go
    assert_match('vacuole inheritance',GO::id2name('GO:0000011'))
    assert_equal(['vacuole inheritance','alpha-glucoside transport'], GO::id2name(['GO:0000011','GO:0000017']))
  end

  def test_ancestors
    assert GO.id2ancestors('GO:0000001').include? 'GO:0048308'
  end

  def test_namespace
    assert_equal 'biological_process', GO.id2namespace('GO:0000001')
  end


end


