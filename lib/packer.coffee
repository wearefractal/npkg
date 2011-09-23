npm = require './npm'
get = require 'get'
path = require 'path'
log = require 'node-log'
fs = require 'fs'
util = require './util'
async = require 'async'
rimraf = require 'rimraf'

copyApp = (dirs, pack, opt, cb) ->
  log.info 'Cloning application...'
  util.cloneDirectory opt.in, dirs.app, true, ['npkg-temp'], cb
      
saveNPM = (dirs, pack, opt, cb) ->
  log.info 'Analyzing dependencies...'
  npm.resolve opt.in, (deps) ->
    log.info 'Downloading/unpacking dependencies...'
    # log.debug JSON.stringify Object.keys deps
      
    saveModule = (dep, call) ->
        obj = deps[dep]
        out = path.join dirs.deps, path.basename(obj.download)
        new get(uri: obj.download).toDisk out, (err, result) ->
          throw err if err
          outf = path.join dirs.npm, dep
          fs.mkdir outf, 0777, (err) ->
            throw err if err
            util.unpack result, outf, true, (err) ->
              if err then log.error 'Unpacking ' + dep + ' failed! Error: ' + err
              call()
        
    async.forEach Object.keys(deps), saveModule, -> rimraf dirs.deps, cb
    return

saveNode = (dirs, pack, opt, cb) ->
  # throw new Error 'Please specify a node engine version in package.json' unless pack.engines and pack.engines.node
  # TODO: Validate NodeJS versions with package.json using semver, make sure windows has a node.exe, all that jazz 
  srcdl = 'http://nodejs.org/dist/node-v0.4.12.tar.gz'
  exedl = 'http://nodejs.org/dist/v0.5.7/node.exe'
  
  dlsrc = (call) ->
    log.info 'Downloading/unpacking NodeJS source...'
    new get(uri: srcdl).toDisk path.join(dirs.node, 'node.tgz'), (err, result) ->
      throw err if err
      srcout = path.join dirs.node, 'src/'
      fs.mkdir srcout, 0777, (err) ->
        throw err if err
        util.unpack result, srcout, true, (err) ->
          throw err if err
          fs.unlink result, (err) ->
            throw err if err
            call()
            
  dlexe = (call) ->    
    log.info 'Downloading node.exe...' 
    new get(uri: exedl).toDisk path.join(dirs.node, 'node.exe'), (err, result) ->
      throw err if err
      call()
        
  async.parallel [dlsrc, dlexe], cb 
    
module.exports =
  save: (dirs, pack, opt, cb) ->
    ## TODO: Writing installation scripts to config folder and app data to app
    npmfn = (call) -> saveNPM dirs, pack, opt, call
    nodefn = (call) -> saveNode dirs, pack, opt, call
    copyfn = (call) -> copyApp dirs, pack, opt, call
    async.parallel [copyfn, npmfn, nodefn], cb
