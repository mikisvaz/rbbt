require 'rbbt/ner/rnorm/tokens'
require 'rbbt/util/misc'
require 'rbbt/util/tmpfile'
require 'rbbt/util/open' 
require 'test/unit' 

class TestCompare < Test::Unit::TestCase 
 
  def setup
    @index = Tokenizer.new  
  end
  
  def test_type   
    assert_equal(:gene, @index.type("gene"))
    assert_equal(:dna, @index.type("dna"))
    assert_equal(:number, @index.type("121"))
  end

  def test_token_types
    assert_equal([["dna", :dna], ["12", :number]], @index.token_types("dna12"))
    assert_equal([["REX", :special], ["12", :number]], @index.token_types("REX12"))
    assert_equal([["SSH", :special], ["3", :number], ["BP", :special]], @index.token_types("SSH3BP"))
    assert_equal([["HP", :special], ["1", :number], ["gamma", :greek]], @index.token_types("HP1gamma"))
    assert_equal([["HP", :special], ["1", :number], ["GAMMA", :greek]], @index.token_types("HP1-GAMMA"))
  end

  def test_eval 
    assert_equal(3, @index.evaluate_tokens(@index.token_types("1"), @index.token_types("1"))) 
  end 

  def test_transforms 
    t = Tokenizer::Transform.new.unknown do |t| [t, if t.length < 4 then :special else :unknown end] end 
    assert_equal(["BP", :special], t.transform(["BP",:unknown]))
  end
  def test_comparisons
    assert_equal(0, Tokenizer::Operation.new(:same).number(3).eval(@index.token_types("SSH1"),@index.token_types("SSH2")))
    assert_equal(3, Tokenizer::Operation.new(:same).number(3).eval(@index.token_types("SSH1"),@index.token_types("SSH1")))
    assert_equal(0, Tokenizer::Operation.new(:same).special(1).eval([["SSH", :special],["1", :number]],[["SSH", :special],["3", :number],["BP",:special]]))
    assert_equal(-1, Tokenizer::Operation.new(:diff).special(-1).eval([["SSH", :special],["1", :number]],[["SSH", :special],["3", :number],["BP",:special]]))
    assert_equal(-1, Tokenizer::Operation.new(:extr).special(-1).eval([["SSH", :special],["1", :number]],[["SSH", :special],["3", :number],["BP",:special]]))
    assert_equal(-1, Tokenizer::Operation.new(:miss).special(-1).eval([["SSH", :special],["3", :number],["BP",:special]],[["SSH", :special],["1", :number]]))
  end
  def test_ignore_case
    assert_equal(-1, Tokenizer::Operation.new(:diff).ignore_case(false).special(-1).eval([["ssh", :special]],[["SSH", :special]]))
    assert_equal(0, Tokenizer::Operation.new(:diff).ignore_case(true).special(-1).eval([["ssh", :special]],[["SSH", :special]]))
  end

  def test_compare
     assert_equal(-10, @index.evaluate("DNA1", "GENE2"))
     assert_equal(3, @index.evaluate("DNA1", "GENE1")) 
     assert_equal(3, @index.evaluate("DNA1", "RNA1")) 
     assert_equal(-1, @index.evaluate("SSH", "SSH1")) 
     assert_equal(7, @index.evaluate("pol III", "POL3")) 
  end 

  def test_default
    index = Tokenizer.new 
    assert(index.evaluate("SSH", "SSH1") > index.evaluate("SSH", "SSH3BP")) 
    assert(index.evaluate("HP1gamma", "HP1-GAMMA") > 1) 
    assert(index.evaluate("HP1alpha", "HP1 alpha") > 1) 
    assert(index.evaluate("IL-1beta", "IL-1 beta") > 1) 
    assert(index.evaluate("IL-1RI", "IL-1R-1") > 1) 
    assert(index.evaluate("MODI", "MOD 1") > 1) 
    assert(index.evaluate("MOD 1", "MODI") > 1) 
    assert(index.evaluate("Ubc3", "Ubc3b") > 1) 
  end
  

end  
