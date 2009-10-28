require 'rbbt/sources/biomart'
require 'test/unit'

class TestBioMart < Test::Unit::TestCase

  def test_get
    assert_raise BioMart::QueryError do 
      BioMart.get('scerevisiae_gene_ensembl','entrezgene', ['protein_id'],['with_unknownattr'])
    end

    data = BioMart.get('scerevisiae_gene_ensembl','entrezgene', ['protein_id'],[])
    assert(data['856452']['protein_id'].include? 'AAB68382')

    data = BioMart.get('scerevisiae_gene_ensembl','entrezgene', ['external_gene_id'],[], data )
    assert(data['856452']['protein_id'].include? 'AAB68382')
    assert(data['856452']['external_gene_id'].include? 'CUP1-2')

  end

  def test_query
    data = BioMart.query('scerevisiae_gene_ensembl','entrezgene', ['protein_id','refseq_peptide','external_gene_id','ensembl_gene_id'],[])

    assert(data['856452']['protein_id'].include? 'AAB68382')
    assert(data['856452']['external_gene_id'].include? 'CUP1-2')

 end

end


