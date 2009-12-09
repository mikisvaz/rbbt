require 'rake'

module Rake::Pipeline

  def step_def(*args)
    Rake::Pipeline::Step.step_def(*args)
  end

  def step_descriptions
    Rake::Pipeline::Step.step_descriptions
  end

  def infile(t, &block)
    File.open(t.prerequisites.first)do |f|
      block.call(f)
    end
  end

  def outfile(t, &block)
    File.open(t.name, 'w')do |f|
      block.call(f)
    end
  end


end

module Rake::Pipeline::Step

  class << self
    @@step_descriptions = {}
    def step_descriptions
      @@step_descriptions
    end

    def add_description(re, step, message)
      @@step_descriptions[re] = "#{ step }: #{ message }"                       
    end

    def step_def(name, dependencies = nil)

      re = Regexp.new(/(?:^|\/)#{name}\/.*$/)
      re = Regexp.new(/#{name}\/.*/)

        # Take the last_description and associate it with the name
        if Rake.application.last_description
          add_description(re, name, Rake.application.last_description)
        end


      # Generate the Hash definition
      case 
      when dependencies.nil?
        re
      when String === dependencies || Symbol === dependencies
        {re => lambda{|filename| filename.sub(name.to_s,dependencies.to_s) }}
      when Array === dependencies
        {re => lambda{|filename| dependencies.collect{|dep| filename.sub(name.to_s, dep.to_s) } }}
      when Proc === dependencies
        {re => dependencies}
      end
    end
  end

end


