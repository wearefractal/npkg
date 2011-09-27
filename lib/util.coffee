path = require 'path'
log = require 'node-log'
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
async = require 'async'

module.exports =
  unpack: (inf, out, striptop, cb) ->
    cmd = 'tar -xvzf ' + inf + ' -C ' + out
    if striptop then cmd += ' --strip 1'
    exec cmd, (err, stdout, stderr) ->
      err ?= stderr if stderr? and !stderr.containsIgnoreCase 'Ignoring unknown extended header keyword'
      cb err
                 
  cloneDirectory: (dir, newdir, ignore, excludes, cb) ->
    if !cb
      cb = excludes
      excludes = []
    
    clone = (file, call) ->
      oldf = path.join dir, file
      newf = path.join newdir, file
      fs.stat oldf, (err, stat) ->
        throw err if err
        if stat.isDirectory()
          module.exports.cloneDirectory oldf, newf, true, excludes, call
        else
          fs.readFile oldf, (err, data) ->
            throw err if err
            fs.writeFile newf, data, (err) ->
              throw err if err
              call()
            
    copyAll = (call) ->
      fs.readdir dir, (err, files) ->
        excludes = excludes.unique()
        files ?= []
        files = (x for x in files when excludes.indexOf(x) is -1) # TODO: REGEX TESTING
        async.forEach files, clone, call
              
    npmExclude = (call) ->
      npmignore = path.join dir, '/.npmignore'
      path.exists npmignore, (exists) ->
        return call() unless exists
        fs.readFile npmignore, (err, data) ->
          throw err if err
          excludes.merge data.toString().split '\n'
          call()
              
    gitExclude = (call) ->
      gitignore = path.join dir, '/.gitignore'
      path.exists gitignore, (exists) ->
        return call() unless exists
        fs.readFile gitignore, (err, data) ->
          throw err if err
          excludes.merge data.toString().split '\n'
          call()
    
    run = (call) ->
      if ignore          
        async.parallel [npmExclude, gitExclude], -> copyAll call
      else
        copyAll call
                 
    path.exists newdir, (exists) ->
      if exists
        run cb
      else
        fs.mkdir newdir, 0755, (err) -> 
          throw err if err
          run cb
            
