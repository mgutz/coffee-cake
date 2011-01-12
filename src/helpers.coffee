# This module common helper functions.
module.exports =

  # Accurately get the type of a value. [crockford](http://javascript.crockford.com/remedial.html)
  typeOf: (value) ->
    s = typeof value
    if s == 'object'
      if value
        if typeof value.length == 'number' && !(value.propertyIsEnumerable('length')) &&
           typeof value.splice == 'function'
            s = 'array'
       else
          s = 'null'
    s
