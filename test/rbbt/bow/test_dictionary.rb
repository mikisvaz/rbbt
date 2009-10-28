require 'rbbt/bow/dictionary'
require 'rbbt/bow/bow'
require 'test/unit'

class TestDictionary < Test::Unit::TestCase
  
  def test_standard
    docs = []
    docs << BagOfWords.terms("Hello World", false)
    docs << BagOfWords.terms("Hello Yin Yin", false)

    dict = Dictionary.new
    docs.each{|doc| dict.add doc}
    
    assert_equal(2, dict.terms["hello"])
    assert_equal(2, dict.terms["yin"])
    assert_equal(0, dict.terms["bye"])
    assert_equal(1, dict.terms["world"])
  end

  def test_tf_idf
    docs = []
    docs << BagOfWords.terms("Hello World", false)
    docs << BagOfWords.terms("Hello Yin Yin", false)


    dict = Dictionary::TF_IDF.new
    docs.each{|doc| dict.add doc}

    assert_equal(2, dict.terms["hello"])
    assert_equal(2, dict.terms["yin"])
    assert_equal(0, dict.terms["bye"])
    assert_equal(1, dict.terms["world"])
 

    assert_equal(1,   dict.df["hello"])
    assert_equal(0.5, dict.df["yin"])
    assert_equal(0,   dict.df["bye"])
    assert_equal(0.5, dict.df["world"])

    assert_equal(2.0/5, dict.tf["hello"])
    assert_equal(2.0/5, dict.tf["yin"])
    assert_equal(0,     dict.tf["bye"])
    assert_equal(1.0/5,   dict.tf["world"])

    assert_equal(Math::log(1), dict.idf["hello"])
    assert_equal(Math::log(2), dict.idf["yin"])
    assert_equal(0,            dict.idf["bye"])
    assert_equal(Math::log(2), dict.idf["world"])

    assert_equal(2.0/5 * Math::log(1),   dict.tf_idf["hello"])
    assert_equal(2.0/5 * Math::log(2), dict.tf_idf["yin"])
    assert_equal(0,                      dict.tf_idf["bye"])
    assert_equal(1.0/5 * Math::log(2), dict.tf_idf["world"])
  end

  def test_best
    docs = []
    docs << BagOfWords.terms("Hello World", false)
    docs << BagOfWords.terms("Hello Yin Yin", false)


    dict = Dictionary::TF_IDF.new
    docs.each{|doc| dict.add doc}

    assert_equal(1, dict.best(:limit => 1).length)
    assert(dict.best(:limit => 1).include? "yin")
  end
 
  def test_kl
    docs = []
    docs << [BagOfWords.terms("Hello World", false), :+]
    docs << [BagOfWords.terms("Hello Cruel World", false), :+]
    docs << [BagOfWords.terms("Hello Yan Yan", false), :-]
    docs << [BagOfWords.terms("Hello Yin Yin", false), :-]


    dict = Dictionary::KL.new
    docs.each{|doc| dict.add *doc}

    assert_equal(0, dict.kl["hello"])
    assert_equal(dict.kl['yan'], dict.kl['yin'])
    assert_in_delta(1 * Math::log(1 / 0.000001), dict.kl["world"],0.01)
    assert_in_delta(0.5 * Math::log(0.5 / 0.000001), dict.kl["cruel"],0.01)
  end


end

 
