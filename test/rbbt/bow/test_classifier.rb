require 'rbbt/bow/classifier'
require 'rbbt/util/tmpfile'
require 'rbbt/util/open'
require 'test/unit'

class TestClassifier < Test::Unit::TestCase

  def test_build_model
    features =<<-EOT
Name	Class	hello	world
row1	-	2	0
row2	+	0	2
    EOT

    featuresfile = TmpFile.tmp_file("test_classifier")
    modelfile = TmpFile.tmp_file("test_classifier")
    Open.write(featuresfile, features)
    Classifier.create_model(featuresfile, modelfile)

    assert(File.exist? modelfile)

    FileUtils.rm featuresfile
    FileUtils.rm modelfile

  end

  def test_classifier
    features =<<-EOT
Name	Class	hello	world
row1	-	2	0
row2	+	0	2
    EOT

    featuresfile = TmpFile.tmp_file("test_classifier")
    modelfile = TmpFile.tmp_file("test_classifier")
    Open.write(featuresfile, features)
    Classifier.create_model(featuresfile, modelfile)

    FileUtils.rm featuresfile

    classifier = Classifier.new(modelfile)

    assert_equal(["hello", "world"], classifier.terms)

    assert_equal(["-", "+"], classifier.classify_feature_array([[1,0],[0,1]]))


    assert_equal({"negative"=>"-", "positive"=>"+"}, classifier.classify_feature_hash({:positive => [0,1], :negative => [1,0]}))
    assert_equal({"negative"=>"-", "positive"=>"+"}, classifier.classify_feature_hash({:positive => [0,1], :negative => [1,0]}))

    assert_equal(["-", "+"], classifier.classify_text_array(["Hello","World"]))

    assert_equal({"negative"=>"-", "positive"=>"+"}, classifier.classify_text_hash({:negative => "Hello", :positive =>"World"}))

    assert_equal('-', classifier.classify("Hello"))                  
    assert_equal(["-", "+"],classifier.classify([[1,0],[0,1]]))
    assert_equal({"negative"=>"-", "positive"=>"+"},classifier.classify({:positive => [0,1], :negative => [1,0]}))   
    assert_equal(["-", "+"],classifier.classify(["Hello","World"]))        
    #assert_equal({"negative"=>"-", "positive"=>"+"},classifier.classify({:negative => "Hello", :positive => "World"}))   


    #assert_nothing_raised do classifier.classify("Unknown terms") end
    #assert_nothing_raised do classifier.classify([]) end

    FileUtils.rm modelfile


  end

end

