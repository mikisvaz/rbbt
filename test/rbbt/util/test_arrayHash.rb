require File.dirname(__FILE__) + '/../../test_helper'
require 'rbbt/util/arrayHash'
require 'test/unit'

class TestArrayHash < Test::Unit::TestCase

  def test_merge_values
    list1 = ["A|B","C"]
    list2 = ["a|b","c"]
    list3 = ["a|b",""]
    list4 = nil

    assert_equal(["A|B|a|b","C|c"], ArrayHash.merge_values(list1,list2))

    assert_equal(["A|B|a|b","C"], ArrayHash.merge_values(list1,list3))

    assert_equal(["a|b|A|B","C"], ArrayHash.merge_values(list3,list1))
    
    assert_equal(["A|B","C"], ArrayHash.merge_values(list4,list1))
  end

  def test_pullout
    data_in = {
      "1" => ['A|B','C'],
      "2" => ['a|b','c']
    }

    data_out0 = {
      'A' => ["1",'C'],
      'B' => ["1",'C'],
      'a' => ["2",'c'],
      'b' => ["2",'c'],
    }

    data_out0_ci = {
      'a' => ["1|2",'C|c'],
      'b' => ["1|2",'C|c'],
    }



    data_out1 = {
      'C' => ["1",'A|B'],
      'c' => ["2",'a|b'],
    }


    assert_equal(data_out0, ArrayHash.pullout(data_in,0, :case_insensitive => false))
    assert_equal(data_out1, ArrayHash.pullout(data_in,1, :case_insensitive => false))
    assert_equal(data_out0_ci, ArrayHash.pullout(data_in,0,:case_insensitive => true))

    assert_equal("1|2", ArrayHash.pullout(data_in,0,:case_insensitive => true, :index => true)['A'])
    assert_equal("1|2", ArrayHash.pullout(data_in,0,:case_insensitive => true, :index => true)['a'])
   
  end

  def test_merge
    hash1 = {
      '1' => ['A','B'],
      '2' => ['a','b'],
    }

    hash2 = {
      '1' => ['C']
    }
    
    hash_merged1 = {
      '1' => ['A','B','C'],
      '2' => ['a','b','']
    }

    hash3 = {
      'A' => ['D']
    }

    hash_merged2 = {
      '1' => ['A','B','D'],
      '2' => ['a','b','']
    }

    hash4 = {
      'D' => ['1']
    }


    assert_equal(hash_merged1, ArrayHash.merge(hash1, hash2, 'main', 'main', :case_insensitive => false))
    assert_equal(hash_merged2, ArrayHash.merge(hash1, hash3, 0, 'main', :case_insensitive => false))
    assert_equal(hash_merged2, ArrayHash.merge(hash1, hash4, 'main', 0, :case_insensitive => false))
  end

  def test_case_insensitive
     hash1 = {
      'c' => ['A','B'],
      'd' => ['a','b'],
    }

    hash2 = {
      'C' => ['D']
    }

    hash_merged1 = {
      'c' => ['A','B',''],
      'd' => ['a','b',''],
      'C' => ['','','D']
    }
 
    hash_merged2 = {
      'c' => ['A','B','D'],
      'd' => ['a','b',''],
    }
   
    assert_equal(hash_merged1, ArrayHash.merge(hash1, hash2, 'main', 'main', :case_insensitive => false))
    assert_equal(hash_merged2, ArrayHash.merge(hash1, hash2, 'main', 'main', :case_insensitive => true))
  
  end

  def test_clean
     data = {
      '1' => ['A','B'],
      '2' => ['a','A'],
     }
     data_clean = {
      '1' => ['A','B'],
      '2' => ['a',''],
     }
     assert_equal(data_clean, ArrayHash.clean(data))

     data = {
      '1' => ['A','B'],
      '2' => ['a','A|b'],
     }
     data_clean = {
      '1' => ['A','B'],
      '2' => ['a','b'],
     }
     assert_equal(data_clean, ArrayHash.clean(data))

     data = {
      '1' => ['A','B'],
      '2' => ['A|a','b'],
     }
     data_clean = {
      '1' => ['A','B'],
      '2' => ['a','b'],
     }
     assert_equal(data_clean, ArrayHash.clean(data))


     data = {
      '1' => ['a1','a2'],
      '2' => ['a3','a4|A1'],
     }
     data_clean = {
      '1' => ['a1','a2'],
      '2' => ['a3','a4'],
     }
     assert_equal(data, ArrayHash.clean(data))
     assert_equal(data_clean, ArrayHash.clean(data, :case_sensitive => true))


  end
  
  
  def test_field_pos
    data = {
      '1' => ['A','B'],
      '2' => ['a','b'],
    }

    table = ArrayHash.new(table, 'Entrez', ['FA', 'FB'])

    assert_equal(0, table.field_pos('FA'))
    assert_equal(:main, table.field_pos('Entrez'))
    assert_equal(:main, table.field_pos('entrez'))

  end

  def test_object_merge
    data1 = {
      '1' => ['A','B'],
      '2' => ['a','b'],
    }
    table1 = ArrayHash.new(data1, 'Entrez', ['FA', 'FB'])

    data2 = {
      '1' => ['C']
    }
    table2 = ArrayHash.new(data2, 'Entrez', ['FC'])

    hash_merged1 = {
      '1' => ['A','B','C'],
      '2' => ['a','b','']
    }
    names1 = %w(FA FB FC)

    table1.merge(table2, 'Entrez', :case_insensitive => false)
    assert_equal(hash_merged1, table1.data)
    assert_equal(names1, table1.fields)


 
    data3 = {
      'b' => ['d']
    }
    table3 = ArrayHash.new(data3, 'FB', ['FD'])
 
    hash_merged2 = {
      '1' => ['A','B','C',''],
      '2' => ['a','b','','d']
    }
    names2 = %w(FA FB FC FD)

   
    table1.merge(table3, 'FB', :case_insensitive => false)
    assert_equal(hash_merged2, table1.data)
    assert_equal(names2, table1.fields)
  end

  def test_remove
    data = {
      '1' => ['A','B'],
      '2' => ['a','b'],
    }
    data2 = {
      '1' => ['B'],
      '2' => ['b'],
    }


    table = ArrayHash.new(data, 'Entrez', ['FA', 'FB'])
    table.remove('FA')

    assert_equal(nil, table.field_pos('FA'))
    assert_equal(['FB'], table.fields)
    assert_equal(data2, table.data)
  end

  def test_process
    data_in = {
      '1' => ['A','B'],
      '2' => ['a','b'],
    }
    data_out = {
      '1' => ['FA(A)','B'],
      '2' => ['FA(a)','b'],
    }

    table = ArrayHash.new(data_in, 'Entrez', ['FA', 'FB'])

    table.process('FA'){|n| "FA(#{n})"}

    assert_equal(data_out, table.data)
  end

end


