npm = require './npm'
get = require 'get'
path = require 'path'
log = require 'node-log'
fs = require 'fs'
util = require './util'
async = require 'async'
rimraf = require 'rimraf'

writeRunners = (dirs, pack, opt, cb) ->
  main =  path.join path.basename(dirs.app), pack.main
  unix = '#!/bin/sh\n'
  unix += 'cd $( dirname "$0" )\n'
  unix += './node/node ./' + main+ '\n'
  
  winblows = './node/node.exe ./' + main + '\r\n'
  
  writeUnix = (call) ->
    fs.writeFile path.join(dirs.temp, 'run'), unix, (err) ->
      throw err if err
      call()
      
  writeWinblows = (call) ->
    fs.writeFile path.join(dirs.temp, 'run.bat'), winblows, (err) ->
      throw err if err
      call()
  async.parallel [writeUnix, writeWinblows], cb
  
copyApp = (dirs, pack, opt, cb) ->
  log.info 'Cloning application...'
  util.cloneDirectory opt.in, dirs.app, true, ['npkg-temp', opt.out], cb

copyScripts = (dirs, pack, opt, cb) ->
  log.info 'Cloning scripts...'
  util.cloneDirectory path.join(__dirname, '/scripts'), dirs.config, false, [], cb
            
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
  # TODO: Validate NodeJS versions with package.json using semver
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
            rimraf path.join(srcout, '/doc'), call # delete nodejs src docs, its like 9mb of crap we dont need
            
  dlexe = (call) ->    
    log.info 'Downloading node.exe...' 
    new get(uri: exedl).toDisk path.join(dirs.node, 'node.exe'), (err, result) ->
      throw err if err
      call()
        
  async.parallel [dlexe], cb 
    
module.exports =
  save: (dirs, pack, opt, cb) ->
    npmfn = (call) -> saveNPM dirs, pack, opt, call
    nodefn = (call) -> saveNode dirs, pack, opt, call
    copyAppfn = (call) -> copyApp dirs, pack, opt, call
    copyScriptsfn = (call) -> copyScripts dirs, pack, opt, call
    unixRun = (call) -> writeRunners dirs, pack, opt, call
    
    async.parallel [copyAppfn, copyScriptsfn, unixRun, npmfn, nodefn], cb
