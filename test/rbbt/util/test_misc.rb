require 'rbbt/util/misc'
require 'test/unit'

class TestIndex < Test::Unit::TestCase

   
  def test_chunk
    a = %w(a b c d e f g h i j k l m)
    assert_equal([["a", "d", "g", "j", "m"], ["b", "e", "h", "k"], ["c", "f", "i", "l"]], a.chunk(3))
  end

  def test_special
    assert "BRC".is_special?
    assert !"bindings".is_special?
  end

end


