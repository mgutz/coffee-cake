# Cake

`Cake` is an enhanced version of `cake` and is 100% backwards-compatible.

## Tasks

The basic work unit in a Cakefile is a task.

    task name, description, [dependencies], (options, done) ->

* name - Name of the task.
* description - [Optional] Description of the task.
* dependencies - [Optional] A list of tasks which must be executed before this task.
  Dependencies execute exactly once, so tasks may be safely referenced multiple times.
* (options, done) - Callback to execute to local statements.
  - options: Parsed options form command line arguments.
  - done: [Optional] Define this argument to convert the task into an async
    task. `done` must be called else a timeout error occurs.

Example:

    # Cleans, generates and runs tests.
    task 'all', 'All tasks', ['clean', 'generate', 'test']

    task 'clean', -> cleanDirectories()

    task 'generate', (options, done) ->
      compileCoffeeFiles done

    task 'test', 'run all tests', ['generate'], ->
      runTests()

## Invoke

Invoke, as its name suggests, invokes a task from within a task. An invoked task
always executes regardless if it was referenced as a dependency.
    
    task 'foo', ->
      invoke 'task1', 'task2', ->
        doSomething()

* tasks - List of tasks.
* () - [Optional] Callback to execute local statements.
