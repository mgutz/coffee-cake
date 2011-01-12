(function() {
  var CoffeeScript, callAction, fs, helpers, markExecuted, missingTask, oparse, options, optparse, path, printTasks, switches, tasks, timeout, timeoutTask, typeOf, _;
  fs = require('fs');
  path = require('path');
  optparse = require('coffee-script/optparse');
  helpers = (CoffeeScript = require('coffee-script')).helpers;
  typeOf = require('./helpers').typeOf;
  _ = require('underscore');
  tasks = {};
  options = {};
  switches = [];
  oparse = null;
  timeout = 15000;
  helpers.extend(global, {
    task: function(name) {
      var action, arg, dependencies, description, i, _ref;
      for (i = 1, _ref = arguments.length; (1 <= _ref ? i < _ref : i > _ref); (1 <= _ref ? i += 1 : i -= 1)) {
        arg = arguments[i];
        switch (typeOf(arg)) {
          case 'string':
            description = arg;
            break;
          case 'function':
            action = arg;
            break;
          case 'array':
            dependencies = arg;
        }
      }
      return tasks[name] = {
        name: name,
        description: description,
        dependencies: dependencies,
        action: action,
        executed: false
      };
    },
    option: function(letter, flag, description) {
      return switches.push([letter, flag, description]);
    },
    invoke: function() {
      var finished, name, names, next, skipExecutedTasks, _i, _len;
      names = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        name = arguments[_i];
        if (typeof name === 'function') {
          finished = name;
        } else if (typeof name === 'boolean') {
          skipExecutedTasks = name;
        } else if (typeof name === 'string') {
          if (!tasks[name]) {
            missingTask(name);
          }
          names.push(name);
        }
      }
      if (skipExecutedTasks) {
        names = _.select(names, (function(name) {
          return !tasks[name].executed;
        }));
      }
      return (next = function() {
        var action, dependencies, executed, _ref;
        if (names.length) {
          name = names.shift();
          _ref = tasks[name], action = _ref.action, dependencies = _ref.dependencies, executed = _ref.executed;
          if (dependencies != null) {
            return invoke.apply(this, dependencies.concat([
              true, (function() {
                return callAction(action, name, next);
              })
            ]));
          } else {
            return callAction(action, name, next);
          }
        } else {
          if (finished != null) {
            return finished();
          }
        }
      })();
    }
  });
  callAction = function(action, name, next) {
    var id;
    if (!(action != null)) {
      return setTimeout((function() {
        return next();
      }), 0);
    } else if (action.length < 2) {
      action(options);
      markExecuted(name);
      return setTimeout((function() {
        return next();
      }), 0);
    } else {
      id = setTimeout((function() {
        return timeoutTask(name);
      }), timeout);
      return action(options, function() {
        clearTimeout(id);
        markExecuted(name);
        return setTimeout((function() {
          return next();
        }), 0);
      });
    }
  };
  markExecuted = function(name) {
    return tasks[name].executed = true;
  };
  exports.run = function(cakefile) {
    if (cakefile == null) {
      cakefile = 'Cakefile';
    }
    return path.exists(cakefile, function(exists) {
      var arg, args, _i, _len, _ref, _results;
      if (!exists) {
        throw new Error("Cakefile not found in " + (process.cwd()));
      }
      args = process.argv.slice(2);
      CoffeeScript.run(fs.readFileSync(cakefile).toString(), {
        fileName: cakefile
      });
      option(null, '--cake-timeout [milliseconds]', 'Timeout for async callbacks');
      oparse = new optparse.OptionParser(switches);
      if (!args.length) {
        return printTasks();
      }
      options = oparse.parse(args);
      if (options['cake-timeout'] != null) {
        timeout = parseInt(options['cake-timeout']);
      }
      _ref = options.arguments;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        arg = _ref[_i];
        _results.push(invoke(arg));
      }
      return _results;
    });
  };
  printTasks = function() {
    var desc, name, spaces, task;
    console.log('');
    for (name in tasks) {
      task = tasks[name];
      spaces = 20 - name.length;
      spaces = spaces > 0 ? Array(spaces + 1).join(' ') : '';
      desc = task.description ? "# " + task.description : '';
      console.log("cake " + name + spaces + " " + desc);
    }
    if (switches.length) {
      return console.log(oparse.help());
    }
  };
  missingTask = function(task) {
    console.log("No such task: \"" + task + "\"");
    return process.exit(1);
  };
  timeoutTask = function(task) {
    console.log("Task timed out: \"" + task + "\"\nTry increasing option `--kake-timeout 15000` ms");
    return process.exit(1);
  };
}).call(this);
