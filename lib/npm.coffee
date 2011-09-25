analyzer = require 'node-dep'

module.exports =
  resolve: (dir, cb) ->
    options =
      package: dir + '/package.json'
      recursive: true
      verbose: true
      
    analyzer.analyze options, (results) ->
      cb results
    
  parsePerson: (str) ->
    name = str.match /^([^\(<]+)/
    url = str.match /\(([^\)]+)\)/
    email = str.match /<([^>]+)>/
    obj = {}
    if name and name[0].trim() then obj.name = name[0].trim() else obj.name = 'Anonymous'
    if email then obj.email = email[1] else email = 'None'
    if url then obj.url = url[1] else obj.url = 'None'
    return obj
