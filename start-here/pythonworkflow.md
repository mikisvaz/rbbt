---
title: Write workflows in Python (PythonWorkflow)
layout: default
parent: Start here
nav_order: 3
---

Rbbt workflows are implemented using Scout’s Workflow engine. In modern Scout-based installs you can:

- define the **workflow** in Ruby (inputs/dependencies/persistence/provenance)
- implement the **task logic** as plain Python functions (with type hints)

This is provided by the **PythonWorkflow** integration (from `scout-rig`).


## Mental model

- A Python task is a normal Python function.
- You register it with `scout.task(...)`.
- The Ruby workflow imports it with `python_task`.
- At runtime the Ruby task executes the Python script in a subprocess (so you can use your normal Python stack).


## Minimal directory layout

A typical workflow ships:

```text
workflow.rb
python/task/hello.py
```


## 1) Define a Python task

Create `python/task/hello.py`:

```python
import scout

def hello(name: str, excited: bool = False) -> str:
    """Greet a user."""
    return f"Hello, {name}{'!' if excited else ''}"

scout.task(hello)
```

Notes:

- Type hints and defaults are used to generate task metadata.
- The docstring becomes the task description.


## 2) Import the Python task into a Ruby workflow

Create `workflow.rb`:

```ruby
require 'scout'

module TestPythonWF
  extend Workflow
  extend PythonWorkflow

  self.name = 'TestPythonWF'

  python_task :hello
end
```

This defines a Scout/Rbbt task named `hello` whose implementation is in `python/task/hello.py`.


## 3) Run the task

Once the workflow is discoverable (depends on your installation/layout), you can run it like any other workflow task:

```bash
rbbt workflow task TestPythonWF hello --name Alice --excited
```


## Advanced notes (what PythonWorkflow supports)

### Metadata mode
A Python task file can be executed directly to print machine-readable metadata:

```bash
python python/task/hello.py --scout-metadata
```

### Return value decoding
The Python runner prints the return value to stdout.

- If it’s JSON, Ruby parses it.
- Otherwise it is treated as a string (or split into lines for array-like declared outputs).

### List inputs
List inputs can usually be passed as:

- a Ruby Array
- a comma-separated string
- a file path whose lines are taken as items


## Next

- [Use workflows as tools for LLM agents]({{ site.baseurl }}/start-here/agent-tools/)
- [Workflow model reference]({{ site.baseurl }}/reference/workflow/)
- [Legacy Workflow tutorial]({{ site.baseurl }}/tutorial/Workflow/)
