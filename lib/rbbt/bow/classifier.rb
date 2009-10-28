require 'rbbt/bow/bow'
require 'rsruby'

# This class uses R to build and use classification models. It needs the
# 'e1071' R package.
class Classifier


  # Given the path to a features file, which specifies a number of instances
  # along with their classes and features in a tab separated format, it uses R
  # to build a svm model which is save to file in the path specified as
  # modelfile.
  def self.create_model(featuresfile, modelfile, dictfile = nil)

    r = RSRuby.instance
    r.source(File.join(Rbbt.datadir, 'classifier/R/classify.R'))
    r.BOW_classification_model(featuresfile, modelfile)

    nil
  end

  attr_reader :terms

  # Loads an R interpreter which loads the svm model under modelfile.
  def initialize(modelfile)
    @r = RSRuby.instance
    @r.library('e1071')
    @r.source(File.join(Rbbt.datadir, 'classifier/R/classify.R'))

    @r.load(modelfile)

    @model = @r.svm_model
    @terms = @r.eval_R("terms = unlist(attr(attr(svm.model$terms,'factors'),'dimnames')[2])")
  end

  def classify_feature_array(input) #:nodoc:
    @r.assign('input', input)

    @r.eval_R('input = t(as.data.frame(input))')
    @r.eval_R('rownames(input) <- NULL')
    @r.eval_R('colnames(input) <- terms')

    results = @r.eval_R('BOW.classification.classify(svm.model, input, svm.weights)')
    results.sort.collect{|p| p[1]}
  end

  def classify_feature_hash(input) #:nodoc:
    names = []
    features = []
    input.each{|name, feats|
      names << name.to_s
      features << feats
    }

    @r.assign('input', features)
    @r.assign('input.names', names)

    @r.eval_R('input = t(as.data.frame(input))')
    @r.eval_R('rownames(input) <- input.names')
    @r.eval_R('colnames(input) <- terms')

    @r.eval_R('BOW.classification.classify(svm.model, input, svm.weights)')
  end

  def classify_text_array(input) #:nodoc:
    features = input.collect{|text|
      BagOfWords.features(text, @terms)
    }

    classify_feature_array(features)
  end

  def classify_text_hash(input) #:nodoc:
    features = {}
    input.each{|key,text|
      features[key] = BagOfWords.features(text, @terms)
    }

    classify_feature_hash(features)
  end


  # This is a polymorphic method. The input variable may be a single input, in
  # which case the results will be just the class, a hash of inputs, in which
  # case the result will be a hash with the results for each input, or an
  # array, in which case the result is an array of the results in the same
  # order. Each input may also be in the form of a string, in which case it
  # will be transformed into a feature vector, or an array in which case it
  # will be considered as an feature vector itself.
  def classify(input)
    if input.is_a? String
      return classify_text_array([input]).first
    end


    if input.is_a? Hash
      return  {} if input.empty?
      if input.values.first.is_a? String
        return classify_text_hash(input)
      elsif input.values.first.is_a? Array
        return classify_feature_hash(input)
      end
    end

    if input.is_a? Array
      return  [] if input.empty?
      if input.first.is_a? String
        return classify_text_array(input)
      elsif input.first.is_a? Array
        return classify_feature_array(input)
      end
    end

  end



end
