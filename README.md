# Cake

`Cake` is an enhanced version of `cake` and is 100% backwards-compatible
(as of this writing).

`jaskenas` wants the `cake` in the `coffee-script` distribution to remain light 
and simple. Fair enough. Let there be Cake!

## Enhancements Over cake

TODO section contains enhancements in the works.

* Asynchronous Tasks

        task 'generate', (options, done) ->
            generateCoffeeScript 'src/', done

* Task Dependencies (async aware)

        task 'all', 'Run all tasks', ['clean', 'generate', 'test']

* Multi-target Invoke. Serially calls each task (async aware)

        invoke 'task1', 'task2', 'taskn', ->
            doStuff()


## Installation

For now, use repository

    git clone git://github.com/mgutz/coffee-cake.git
    cd cofee-cake
    npm link

## To test

    cd test
    Cake test

## TODO

* [TODO] File task helpers

        task 'app.js'
            file = 'public/jss/app.js' 
            scripts = find('lib/scripts', '/\.js$/') # recursive
            if outdated(file, scripts)
                concatenateFiles file, scripts
            
* [TODO] Toolbelt Helper Functions
  - outdated(target, dependenciesList)
  - prependToFile(file, text)
  - appendToFile(file, text)
  - writeToFile(file, text)
  - gsubFile(file, pattern, replacement)
  - concatenateFiles(file, fileList)
  - removeDirectory(dir, {recursive, safe})
  - makeDirectory(dir, {recursive, safe})
  - copyDirectory(dir, {safe})

