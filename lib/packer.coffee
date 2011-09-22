npm = require './npm'
get = require 'get'
path = require 'path'
log = require 'node-log'

saveNPM = (dirs, pack, opt, cb) ->
  npm.resolve opt.in, (deps) ->
    left = Object.keys(deps).length
    for dep of deps
      obj = deps[dep]
      out = path.join(dirs.deps, path.basename(obj.download))
      new get(uri: obj.download).toDisk out, (err, data) ->
        left--
        if err
          cb err
        else
          if left is 0
            cb null  

saveNode = (dirs, pack, opt, cb) ->
  unless pack.engines and pack.engines.node
    return cb new Error 'Please specify a node engine version in package.json'  
  ###
  # nodeVersion = parseFloat pack.engines.node
  nodeVersion = '0.4.12' # unix
  # nodeVersion = 0.5.7 # windows
  # TODO: Validate NodeJS versions with package.json using semver, make sure windows has a node.exe, all that jazz
  ###
  log.info 'Downloading latest NodeJS stable/unstable releases'
  
  srcdl = 'http://nodejs.org/dist/node-v0.4.12.tar.gz'
  exedl = 'http://nodejs.org/dist/v0.5.7/node.exe'
  new get(uri: srcdl).toDisk path.join(dirs.node, 'node.tar.gz'), (err, data) ->
    if err
      cb err
    else
      new get(uri: exedl).toDisk path.join(dirs.node, 'node.exe'), (err, data) ->
        if err
          cb err
        else
          cb null
          
module.exports =
  save: (dirs, pack, opt, cb) ->
    saveNPM dirs, pack, opt, (err) ->
      return cb err if err
      saveNode dirs, pack, opt, (err) ->
        return cb err if err
        cb null ## TODO: Writing installation scripts to config folder and app data to app
