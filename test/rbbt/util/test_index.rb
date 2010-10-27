require File.dirname(__FILE__) + '/../../test_helper'
require 'rbbt/util/index'
require 'test/unit'

class TestIndex < Test::Unit::TestCase

   
  def test_index
    require 'rbbt/util/tmpfile'
    require 'rbbt/util/open'

    tmp = TmpFile.tmp_file('test_open-')
    data =<<-EOD
S000006236 856144 YPR032W YPR032W NP_015357 SNI1_YEAST Q12038|Q12038 CAA95028|CAA89286 SRO7
S000001262 856629 YHR219W YHR219W NP_012091 YH19_YEAST P38900 AAB69742 YHR219W
    EOD
    Open.write(tmp,data)

    index = Index.index(tmp,:sep => " ", :sep2 => "|")
    assert_equal('S000001262', index['AAB69742'] )
    assert_equal('S000006236', index['Q12038']  )

    FileUtils.rm tmp
    
 end



end


