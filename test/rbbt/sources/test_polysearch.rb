require File.dirname(__FILE__) + '/../../test_helper'
require 'rbbt'
require 'rbbt/util/tmpfile'
require 'rbbt/sources/polysearch'
require 'test/unit'

class TestPolysearch < Test::Unit::TestCase

  def test_match
    text =<<-EOT

    Analysis of sorted peripheral blood lymphocytes (CD8 T cells, CD4 T cells,
    B cells, NK cells) from patients with melanoma. These subpopulations are
    involved in antitumor responses and negatively impacted by cancer. Results
    provide insight into molecular mechanisms of immune dysfunction in cancer.

    EOT

    assert_equal(["B cells", "T cells", "blood", "lymphocytes",  "peripheral blood", "peripheral blood lymphocytes"].sort, Polysearch.match(text,nil).values.flatten.uniq.sort) 
  end

  def test_name
    assert_equal('ligament', Polysearch.name('organ','OR00039'))
  end
end


