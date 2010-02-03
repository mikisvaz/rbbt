require File.dirname(__FILE__) + '/../../test_helper'
require 'rbbt/ner/rnorm/cue_index'
require 'rbbt/util/misc'
require 'rbbt/util/tmpfile'
require 'rbbt/util/open'
require 'test/unit'

class TestCUE < Test::Unit::TestCase

  def setup
    @index = CueIndex.new do
      equal    do |w| [w] end
      standard do |w| [w.downcase.split(/\s+/).sort.join("")] end
      special  do |w| s = w.split.select{|w| w.is_special?}.collect{|w| w.downcase.sub(/p$/,'')} end
      words    do |w| 
        w.scan(/[a-z]+/i).
          select{|w| w.length > 2}.
          sort{|a,b| b.length <=> a.length}. 
          collect{|n| n.downcase}
      end
    end
  end

  def test_cue
    assert_equal([["Hsp70 gene"], ["genehsp70"], ["hsp70"], ["gene", "hsp"]], @index.cues("Hsp70 gene"))
  end

  def test_load
    tmp = TmpFile.tmp_file("test_cue")

    lexicon =<<-EOT
code1\tNAME1\tname 1
code2\tNAME2\tname 2
    EOT
    Open.write(tmp,lexicon)

    assert_raise(CueIndex::LexiconMissingError){@index.match("NAME2")}
    @index.load(tmp)
    assert_equal(["code2"], @index.match("NAME2"))

    FileUtils.rm tmp
  end

  #def test_yeast
  #  index  = CueIndex.new
  #  index.load(File.join(Rbbt.datadir,'biocreative','BC1GN','yeast','synonyms.list'))
  #  assert(index.match("Met - 31").include? 'S0005959')
  #end

  #def test_mouse
  #  index  = CueIndex.new
  #  index.load(File.join(Rbbt.datadir,'biocreative','BC1GN','mouse','synonyms.list'))
  #  puts index.match("kreisler gene").length
  #end


end
