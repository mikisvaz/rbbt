def step(name, previous = nil, &block)
  previous ||= []
  previous = [previous] unless Array === previous

  rule(/#{name}\/*/) do |task|
    previous.each{|prev|
      filename = task.name.sub(name.to_s, prev.to_s)
      Rake::Task[filename].invoke
      task.enhance([filename])
    }
    block.call(task)
  end
end


