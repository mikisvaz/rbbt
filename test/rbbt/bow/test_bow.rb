require 'rbbt/bow/bow'
require 'test/unit'

class TestBow < Test::Unit::TestCase

  def test_words
    assert_equal(["hello", "world"], "Hello World".words)

  end
   
  def test_terms
    text = "Hello World"
    assert_equal(["hello", "world"], BagOfWords.terms(text,false).keys.sort)
    assert_equal(["hello", "hello world", "world"], BagOfWords.terms(text,true).keys.sort)
  end

  def test_features

    text = "Hello world!"
    text += "Hello World Again!"

    assert_equal([2, 2], BagOfWords.features(text, "Hello World".words.uniq.sort))
  end

  def test_stem
    assert_equal(["protein"], "Proteins".words)
  end


end


