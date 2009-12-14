require 'rbbt/util/open'
require 'test/unit'

class TestOpen < Test::Unit::TestCase

  def test_remote

    assert(  Open.remote("http://localhost:20002/asdf.html"))
    assert(! Open.remote("/tmp/foo.xml"))

  end

  def test_gziped
    assert(Open.gziped("/tmp/foo.xml.gz"))
    assert(Open.gziped("http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association.goa_human.gz?rev=HEAD"))
    assert(Open.gziped("http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association.goa_human.gz"))
  end

  def test_read_write
    require 'rbbt/util/tmpfile'
    require 'fileutils'

    tmp     = TmpFile.tmp_file('test-')

    content = "test content"
    
    Open.write(tmp, content)    
    assert(Open.read(tmp) == content)

    assert_equal("tast contant", Open.read(IO::popen("cat #{ tmp }|tr 'e' 'a'")))

    FileUtils.rm(tmp)
  end

  def test_append
    require 'rbbt/util/tmpfile'
    require 'fileutils'

    tmp      = TmpFile.tmp_file('test-')
    content1 = "test content1"
    content2 = "test content2"

    Open.write(tmp, content1)
    Open.append(tmp, content2)
    assert(Open.read(tmp) == content1 + content2)
    FileUtils.rm(tmp)
  end


  def test_read_remote
    url ="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=16438716" 

    assert(Open.read(url, :quiet =>true) =~ /Discovering semantic features in the literature: a foundation for building functional associations./)
  end
    
  def test_to_hash
    require 'rbbt/util/tmpfile'

    tmp = TmpFile.tmp_file('test_open-')
    data =<<-EOD
row1 a b 3
row1 aa bb 33
row2 a d e r
    EOD
    Open.write(tmp,data)

    data = Open.to_hash(tmp, :native => 1,:extra => [2,3],:sep => " ")
    assert(data['a'][0].include?('b') && data['a'][0].include?('d'))
    
    data = Open.to_hash(tmp,:native => 1, :sep => " ")
    assert(data['a'][1].include?('b') && data['a'][1].include?('d'))

    data = Open.to_hash(tmp,:native => 1, :sep => " ", :flatten => true)
    assert_equal({"aa"=>["row1", "bb", "33"], "a"=>["row1", "row2", "b", "d", "3", "e", "r"]}, data)
    
    data = Open.to_hash(tmp,:native => 1, :sep => " ", :single => true)
    assert_equal({"aa"=>"row1", "a"=>"row1"}, data)
    
    FileUtils.rm tmp
  end

  def test_fields
    assert_equal(["1","2"] , Open.fields("1\t2") )
    assert_equal(["1","2",""] , Open.fields("1\t2\t") )
    assert_equal(["","",""] , Open.fields("\t\t") )
  end




end


