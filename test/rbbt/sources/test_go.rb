
require 'rbbt/sources/go'
require 'test/unit'

class TestGo < Test::Unit::TestCase

  def test_go
    assert_match('vacuole inheritance',GO::id2name('GO:0000011'))
    assert(GO::id2name(['GO:0000011','GO:0000017']) == ['vacuole inheritance','alpha-glucoside transport'])
  end

end


