npm = require './npm'
get = require 'get'
path = require 'path'
log = require 'node-log'
fs = require 'fs'
exec = require('child_process').exec

# Extracts packages from deps folder and outputs them as node_modules subfolders
unpackModules = (dirs, cb) ->
  log.info 'Unpacking dependencies'
  fs.readdir dirs.deps, (err, files) ->
    left = files.length
    for file in files
      do (dirs, cb) ->
        temp = file.split('-')
        pack = temp[0...temp.length-1].join '-'
        out = path.join dirs.npm, pack
        inf = path.join dirs.deps, file
        fs.mkdir out, 0777, (err) ->
          throw err if err
          cmd = 'tar -xvzf ' + inf + ' -C ' + out + ' --strip 1'
          log.debug cmd
          exec cmd, (err, stdout, stderr) ->
            throw err if err
            log.debug out
            log.error stderr if stderr
            left--
            if left is 0
              cb null
    return
    
saveNPM = (dirs, pack, opt, cb) ->
  log.info 'Analyzing dependencies...'
  npm.resolve opt.in, (deps) ->
    log.info 'Downloading dependencies...'
    log.debug JSON.stringify Object.keys deps
    left = Object.keys(deps).length
    for dep of deps
      do (dep, deps, cb) ->
        obj = deps[dep]
        out = path.join(dirs.deps, path.basename(obj.download))
        new get(uri: obj.download).toDisk out, (err, result) -> # Download the tarball from the NPM registry
          throw err if err
          left--
          if left is 0
            cb null
    return

saveNode = (dirs, pack, opt, cb) ->
  return cb null # Skip
  throw new Error 'Please specify a node engine version in package.json' unless pack.engines and pack.engines.node
  ###
  # nodeVersion = parseFloat pack.engines.node
  # TODO: Validate NodeJS versions with package.json using semver, make sure windows has a node.exe, all that jazz
  ###
  log.info 'Downloading latest NodeJS releases'
  
  srcdl = 'http://nodejs.org/dist/node-v0.4.12.tar.gz'
  exedl = 'http://nodejs.org/dist/v0.5.7/node.exe'
  new get(uri: srcdl).toDisk path.join(dirs.node, 'node.tar.gz'), (err, result) ->
    throw err if err
    new get(uri: exedl).toDisk path.join(dirs.node, 'node.exe'), (err, result) ->
      throw err if err
      cb null
          
module.exports =
  save: (dirs, pack, opt, cb) ->
    saveNPM dirs, pack, opt, (err) ->
      throw err if err
      saveNode dirs, pack, opt, (err) ->
        throw err if err
        unpackModules dirs, cb
        ## TODO: Writing installation scripts to config folder and app data to app
