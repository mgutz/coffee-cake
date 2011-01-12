# Cake

`Cake` is an enhanced version of `cake` and is 100% backwards-compatible
(as of this writing).

`jaskenas` wants to keep the `cake` in the `coffee-script` distribution to be 
light and simple. Fair enough. Let there be Cake! 


## Enhancements Over cake

Sections marked TODO are work in progress.

* Asynchronous Tasks

        task 'generate', (options, done) ->
            generateCoffeeScript 'src/', done

* Task Dependencies

        task 'all', 'Run all tasks', ['clean', 'generate', 'test']

* Multi-target Invoke. Serially calls each task

        invoke 'task1', 'task2', 'taskn', ->
            doStuff()

* [TODO] File task helpers

        task 'app.js'
            file = 'public/jss/app.js' 
            scripts = find('lib/scripts', '/\.js$/')
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

