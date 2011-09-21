npm = require './npm'
get = require 'get'
path = require 'path'

saveDependencies = (dirs, pack, opt, cb) ->
  npm.resolve opt.in, (deps) ->
    left = Object.keys(deps).length
    for dep of deps
      obj = deps[dep]
      out = path.join(dirs.deps, path.basename(obj.download))
      new get(uri: obj.download).toDisk out, (err, data) ->
        left--
        if err
          cb new Error err
        else
          if left is 0
            cb null
                
module.exports =
  save: (dirs, pack, opt, cb) ->
    saveDependencies dirs, pack, opt, (err) ->
      if err then cb err
      else cb null ## TODO: Writing installation scripts to config folder and app data to app and node ver to node etc. goes here
          
