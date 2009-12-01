require 'rbbt'
require 'rbbt/util/tmpfile'
require 'rbbt/util/open'
require 'rbbt/ner/dictionaryNER'
require 'test/unit'

class TestDictionaryNER < Test::Unit::TestCase

  def setup
    @dictionary  =<<-EOT
DICT1\tWord1 Word2\tWord1
DICT2\tWord3-Word4\tWord4
    EOT

    @dict = {
      "word1" => [{'word2' => ['DICT1'] }, 'DICT1'],
      "word3" => [{'word4' => ['DICT2'] }],
      "word4" => ['DICT2'],
    }
  end

  def test_simplify
    assert_equal('word1', DictionaryNER.simplify( "Word1"))
    assert_equal('ACL', DictionaryNER.simplify("ACL"))
  end

  def test_chunk
    assert_equal(["Word1","Word2"], DictionaryNER.chunk('Word1-Word2'))
    assert_equal(["Word1-1"], DictionaryNER.chunk('Word1-1'))
  end

  def test_match

    [
      
      ["Word1", {"word1" => ["D1"]}, {"Word1" => ["D1"]}],
      
      ["Word1 Word1", {"word1" => ["D1"]}, {"Word1" => ["D1"]}],
      
      ["Word2 Word1 Word3", {"word1" => ["D1"]}, {"Word1" => ["D1"]} ],

      ["Word2 Word1 Word4", {"word1" => ["D1","D2"]}, {"Word1" => ["D1","D2"]} ],

      ["Word2 Word1 Word4", 
        {"word1" => [{'word2' => ['D1']}]}, 
        {} ],

      [
        "Word2 Word1 Word4", 
        {"word1" => [ {'word4' => ['D1']} ] }, 
        {"Word1 Word4" => ["D1"]}, 
      ],

      [
        "Word2 Word1 Word4", 
        {"word1" => [ {'word4' => ['D1']} ], "word4" => ['D2'] }, 
        {"Word1 Word4" => ["D1"], "Word4" => ['D2']}, 
      ],


    ].each{|match_info|
      text   = match_info[0]
      dict   = match_info[1]
      result = match_info[2]
      assert_equal(result, DictionaryNER.match(dict, text))
    }

  end

  def test_add_name
    
    [
      
      ["Word1", {"word1" => ['code']}],

      ["Word1 Word2", {"word1" => [{"word2" => ['code']}]}],

      ["Cerebellar stroke syndrome", {"cerebellar" => [{'stroke' => [{'syndrome' => ['code']}]}]}]

    ].each{|info|
      name = info[0]
      result = info[1]

      dict = {}
      DictionaryNER.add_name(dict, name, 'code')
      assert_equal(result, dict)
    }

  end

  def test_load
    assert_equal(@dict, DictionaryNER.load(@dictionary))
  end

  def test_class
    ner = DictionaryNER.new(@dictionary)

    [
      [ "Word1 Word2", ["Word1 Word2", "Word1"] ],
      [ "foo Word1 Word2 foo", ["Word1 Word2", "Word1"] ],
      [ "Word1-Word2", ["Word1 Word2", "Word1"] ],
      [ "Word1\nWord2", ["Word1 Word2", "Word1"] ],
    ].each{|info|
      text = info[0]
      keys = info[1]

      assert_equal(keys.sort, ner.match(text).keys.sort)
    }
  end

  def test_load_from_file
    tmpfile = TmpFile.tmp_file

    Open.write(tmpfile, @dictionary)

    ner = DictionaryNER.new(tmpfile)

    assert(ner.match("Word1").any?)
  end

end

