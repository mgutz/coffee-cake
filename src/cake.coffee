# `cake` is a simplified version of [Make](http://www.gnu.org/software/make/)
# ([Rake](http://rake.rubyforge.org/), [Jake](http://github.com/280north/jake))
# for CoffeeScript. You define tasks with names and descriptions in a Cakefile,
# and can call them from the command line, or invoke them from other tasks.
#
# Running `cake` with no arguments will print out a list of all the tasks in the
# current directory's Cakefile.

# External dependencies.
fs = require('fs')
path = require('path')
optparse = require('coffee-script/optparse')
{helpers} = CoffeeScript = require('coffee-script')
{typeOf} = require('./helpers')
_ = require('underscore')

# Keep track of the list of defined tasks, the accepted options, and so on.
tasks     = {}
options   = {}
switches  = []
oparse    = null

# Default timeout for asynchronous tasks.
timeout   = 15000

# Mixin the top-level Cake functions for Cakefiles to use directly.
helpers.extend global,

  # Define a Cake task with a short name, an optional sentence description,
  # and the function to run as the action itself.
  task: (name) ->
    # Arguments are optional and order is not enforced to maintain
    # compatibility with cake
    #
    # args: name, description, depencies, action
    for i in [1...arguments.length]
      arg = arguments[i]
      switch typeOf arg
        when 'string' then description = arg
        when 'function' then action = arg
        when 'array' then dependencies = arg
    tasks[name] = {name, description, dependencies, action, executed: false}
    
  # Define an option that the Cakefile accepts. The parsed options hash,
  # containing all of the command-line options passed, will be made available
  # as the first argument to the action.
  option: (letter, flag, description) ->
    switches.push [letter, flag, description]

  # Invoke one or more tasks in the current file, and an optional callback 
  # when all tasks have completed.
  invoke: ->
    # Collect all names and find optional callback.
    names = []
    for name in arguments
      if typeof name == 'function'
        finished = name
      else if typeof name == 'boolean'
        skipExecutedTasks = name
      else if typeof name == 'string'
        missingTask name unless tasks[name]
        names.push name

    if skipExecutedTasks
      names = _.select(names, ((name)-> !tasks[name].executed))

    # Serially invoke each task.
    do next = ->
      if names.length
        name = names.shift()
        {action, dependencies, executed} = tasks[name]

        # Invokes dependencies, then action. Note the use of the `true`
        # argument which results in `invoke` not re-executing actions.
        if dependencies?
          invoke.apply this, dependencies.concat([true, (-> callAction action, name, next )])
        else
          callAction action, name, next
      else
        finished() if finished?

# Calls an action.
callAction = (action, name, next) ->
  if !action?
    setTimeout (-> next()), 0

  # Synchronous action.
  else if action.length < 2
    action options
    markExecuted name
    setTimeout (-> next()), 0

  # Asynchronous actions are declared with a callback.
  else
    # Guard against long running actions by setting a user overridable timeout. 
    id = setTimeout (-> timeoutTask name), timeout
    action options, ->
      clearTimeout id
      markExecuted name
      setTimeout (-> next()), 0

# Marks a task `name` as having executed.
markExecuted = (name) ->
  tasks[name].executed = true

# Run `cake`. Executes all of the tasks you pass, in order. 
# If no tasks are passed, print the help screen.
exports.run = (cakefile='Cakefile')->
  path.exists cakefile, (exists) ->
    throw new Error("Cakefile not found in #{process.cwd()}") unless exists
    args = process.argv.slice 2
    CoffeeScript.run fs.readFileSync(cakefile).toString(), fileName: cakefile
    option null, '--cake-timeout [milliseconds]', 'Timeout for async callbacks'
    oparse = new optparse.OptionParser switches
    return printTasks() unless args.length
    options = oparse.parse(args)
    timeout = parseInt(options['cake-timeout']) if options['cake-timeout']?
    invoke arg for arg in options.arguments

# Display the list of Cake tasks in a format similar to `rake -T`
printTasks = ->
  console.log ''
  for name, task of tasks
    spaces = 20 - name.length
    spaces = if spaces > 0 then Array(spaces + 1).join(' ') else ''
    desc   = if task.description then "# #{task.description}" else ''
    console.log "cake #{name}#{spaces} #{desc}"
  console.log oparse.help() if switches.length

# Print an error and exit when attempting to call an undefined task.
missingTask = (task) ->
  console.log "No such task: \"#{task}\""
  process.exit 1

# Print an error and exit when a tasks times out.
timeoutTask = (task) ->
  console.log "Task timed out: \"#{task}\"\nTry increasing option `--kake-timeout 15000` ms"
  process.exit 1
