require 'rake'

module Rake::Pipeline

  module Rake::Pipeline::Step

    class << self
      @@step_descriptions = {}
      def step_descriptions
        @@step_descriptions
      end

      def add_description(re, step, message)
        @@step_descriptions[re] = "#{ step }: #{ message }"                       
      end

      def input(t)
        infile(t) do |f| 
          case 
          when t =~ /.yaml$/
            YAML.load(f)
          when t =~ /.marshal$/
            Marshal.load(f)
          else
            f.read
          end
        end
      end


      @@last_step = nil
      def step_def(name, dependencies = nil)

        re = Regexp.new(/(?:^|\/)#{name}\/.*$/)
        re = Regexp.new(/#{name}\/.*/)

        # Take the last_description and associate it with the name
        if Rake.application.last_description
          add_description(re, name, Rake.application.last_description)
        end

        if dependencies.nil? && ! @@last_step.nil?
          dependencies = @@last_step
        end
        @@last_step = name

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



  def step_descriptions
    Rake::Pipeline::Step.step_descriptions
  end


  def step_def(*args)
    Rake::Pipeline::Step.step_def(*args)
  end

  def infile(t, &block)
    File.open(t.prerequisites.first) do |f|
      block.call(f)
    end
  end

  def outfile(t, &block)
    File.open(t.name, 'w') do |f|
      block.call(f)
    end
  end

  def input
    @input[t.nane] ||= input(t)
  end

  def step(name, dependencies = nil, &block)
    new_block = proc do |t|
      input = input(t)
      output = block.call(t)


    end

  end

end

