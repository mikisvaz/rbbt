require 'rbbt/sources/biocreative'
require 'test/unit'

class TestBiocreative < Test::Unit::TestCase

  def test_BC2GM
    assert(Biocreative.BC2GM(:test)['BC2GM000008491'][:text] == "Phenotypic analysis demonstrates that trio and Abl cooperate in regulating axon outgrowth in the embryonic central nervous system (CNS).")
    assert(Biocreative.BC2GM(:test)['BC2GM000008491'][:mentions] == ["trio", "Abl"] )
  end

  def test_position
    mention   = "IgA"
    text      = "Early complement components, C1q and C4, and IgA secretory piece were absent."
    pos       = [[38, 40]]
    assert(Biocreative.position(text,mention) == pos)

    mention   = "tyrosine-specific phosphatase"
    text      = "When expressed in Escherichia coli, SH-PTP2 displays tyrosine-specific phosphatase activity."
    pos       = [[46, 73]]
    assert(Biocreative.position(text,mention) == pos)

    mention   = "tyrosine - specific phosphatase"
    text      = "When expressed in Escherichia coli, SH-PTP2 displays tyrosine-specific phosphatase activity."
    pos       = [[46, 73]]
    assert(Biocreative.position(text,mention) == pos)

    mention   = "LH"
    text      = "A new direct hemagglutination test (HI-GONAVIS) for urinary LH was compared with the serum radioimmuno-assay of LH."
    pos       = [[52, 53],[96, 97]]
    assert(Biocreative.position(text,mention) == pos)

  end


end


