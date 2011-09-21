analyzer = require 'node-dep'

module.exports =
  resolve: (dir, cb) ->
    options =
      package: dir + '/package.json'
      recursive: true
      verbose: true
      
    analyzer.analyze options, (results) ->
      cb results
    
