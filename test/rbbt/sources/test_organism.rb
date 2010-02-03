require 'rbbt/sources/organism'
require 'test/unit'

class TestOrganism < Test::Unit::TestCase

  def test_all
    assert Organism.all.include? 'Sc'
  end

  def test_ner
    assert(Organism.ner(:Sc, :abner).is_a? Abner)
  end

  def test_norm
    assert_equal(["S000003008"], Organism.norm(:Sc).select(['S000029454','S000003008'],'SLU1', 'SLU1 has been used in the literature to refer to both HEM2/YGL040C, which encodes a porphobilinogen synthase and SLU1, which is essential for splicing.'))

  end

  def test_supported_ids

    ids = Organism.supported_ids('Sc', :examples => true)
    assert(ids.first[0] == 'SGD DB Id' && ids.first[1] =~ /^S00/)
    
    ids = Organism.supported_ids('Sc')
    assert(ids.first == 'SGD DB Id')
  end

  def test_index
    index = Organism.id_index('Sc')
    assert_equal("S000004431", index['851160'])
  end

  def test_index_partial
    index = Organism.id_index('Sc',:other => ['Ensembl Gene ID', 'Protein ID'])
    assert_nil(index['851160'])
    assert_equal("S000000838", index['YER036C'])
    
    index = Organism.id_index('Sc',:other => ['Ensembl Gene ID', 'Protein ID'], :native => "Entrez Gene ID")
    assert_equal("856758", index['YER036C'])

  end

  def test_go_terms

    begin
      goterms = Organism.goterms('Sc')
      assert(goterms["S000000838"].include? "GO:0016887")
    rescue
      puts $!
      puts "No goterm produces, see if code is installed"
    end

  end


end


