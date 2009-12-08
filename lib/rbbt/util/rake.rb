def step(name, previous = nil, &block)
  re = Regexp.new(/(?:^|\/)#{name}\/.*$/)

  $step_descriptions ||= {}
  if Rake.application.last_description 
    $step_descriptions[re] = {:step => name, :message => Rake.application.last_description}
    Rake.application.last_description = nil
  end

  if previous.nil?
    deps = []
  else
    deps = lambda{|filename| filename.sub(name.to_s, previous.to_s)}
  end

  Rake.application.create_rule(re => deps, &block) 
end

