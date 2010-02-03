require File.dirname(__FILE__) + '/../../test_helper'
require 'rbbt'
require 'rbbt/ner/rner'
require 'test/unit'

class TestRNer < Test::Unit::TestCase

  def setup
    @parser = NERFeatures.new do
      isLetters     /^[A-Z]+$/i 
      context prefix_3      /^(...)/ 
      downcase do |w| w.downcase end

      context %w(downcase)
    end
  end

  def test_config
    config = <<-EOC
  isLetters(/^[A-Z]+$/i)
  context(prefix_3(/^(...)/))
  downcase { |w| w.downcase }
  context(["downcase"])
    EOC

    assert(@parser.config == config)
  end

  def test_reverse
    assert_equal("protein P53", NERFeatures.reverse("P53 protein"))
    assert_equal(
       ". LH of assay - radioimmuno serum the with compared was LH urinary for ) GONAVIS - HI ( test hemagglutination direct new A", 
     NERFeatures.reverse(
       "A new direct hemagglutination test (HI-GONAVIS) for urinary LH was compared with the serum\n radioimmuno-assay of LH."
      ))
  end

  def test_features
    assert(@parser.features("abCdE"),["abCdE",true,'abc','abcde'])
  end

  def test_template
    template =<<-EOT
UisLetters: %x[0,1]
Uprefix_3: %x[0,2]
Uprefix_3#1: %x[1,2]
Uprefix_3#-1: %x[-1,2]
Udowncase: %x[0,3]
Udowncase#1: %x[1,3]
Udowncase#-1: %x[-1,3]
B
    EOT
    
    assert(@parser.template == template)
  end

  def test_tokens
    assert( NERFeatures.tokens("A new direct hemagglutination test (HI-GONAVIS) for urinary LH was compared with the serum\n radioimmuno-assay of LH.")==
           ["A", "new", "direct", "hemagglutination", "test", "(", "HI", "-", "GONAVIS", ")", "for", "urinary", "LH", "was", "compared", "with", "the", "serum", "radioimmuno", "-", "assay", "of", "LH", "."])


  end
  def test_text_features
 
    assert(@parser.text_features("abCdE 1234") == [["abCdE",true, "abC", "abcde"], ["1234",false, "123", "1234"]])
    assert(@parser.text_features("abCdE 1234",true) == [["abCdE",true, "abC", "abcde",1], ["1234",false, "123", "1234",2]])
    assert(@parser.text_features("abCdE 1234",false) == [["abCdE",true, "abC", "abcde",0], ["1234",false, "123", "1234",0]])
   
  end

  def test_tagged_features
    assert_equal(
      [["phosphorilation",true, "pho", "phosphorilation", 0], 
        ["of",true, false, "of", 0], 
        ["GENE1",false, "GEN", "gene1", 1],
        [".", false, false, ".", 0]],
      @parser.tagged_features("phosphorilation of GENE1.",['GENE1']))

      assert_equal(
        [["GENE1",false, "GEN", "gene1", 1],
          ["phosphorilation",true, "pho", "phosphorilation", 0]], 
      @parser.tagged_features("GENE1 phosphorilation",['GENE1']))

 
    assert_equal(
           [["phosphorilation",true, "pho", "phosphorilation", 0], 
            ["of",true, false, "of", 0], 
            ["GENE",true, "GEN", "gene", 1],
            ["1",false, false, "1", 2],
            [".", false, false, ".", 0]],
      @parser.tagged_features("phosphorilation of GENE 1.",['GENE 1']))
  end

  def test_tagged_features_reverse
    @parser.reverse = true
    assert_equal(
      [
        ["GENE1",false, "GEN", "gene1", 1],
        ["of",true, false, "of", 0], 
        ["phosphorilation",true, "pho", "phosphorilation", 0]
    ],
    @parser.tagged_features("phosphorilation of GENE1",['GENE1']))

    assert_equal(
          [
            [".", false, false, ".", 0],
            ["1",false, false, "1", 1],
            ["GENE",true, "GEN", "gene", 2],
            ["of",true, false, "of", 0], 
            ["phosphorilation",true, "pho", "phosphorilation", 0]
        ],
    @parser.tagged_features("phosphorilation of GENE 1.",['GENE 1']))
  end


  def test_NER_default
    parser = NERFeatures.new

    assert(parser.template =~ /UisLetter/)
  end

  def test_CRFPP_install
    assert(require File.join(Rbbt.datadir, 'third_party/crf++/ruby/CRFPP'))
  end

end
