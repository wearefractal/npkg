log = require 'node-log'
log.setName 'npkg'

rimraf = require 'rimraf'
fs = require 'fs'
path = require 'path'
packer = require './packer'
izpack = require './izpack'

module.exports = 
  build: (temp, opt, cb) ->
    throw 'Missing parameters' unless opt
    pack = JSON.parse fs.readFileSync path.join(opt.in, 'package.json')
    throw 'Failed to find package.json in ' + opt.in unless pack
    throw '"name" property not in package.json' unless pack.name
    
    log.info 'Starting ' + pack.name + ' build'
    dirs = {}
    dirs.temp = temp
    dirs.node = path.join temp, 'node/'
    dirs.deps = path.join temp, 'deps/'
    dirs.npm = path.join dirs.node, 'node_modules/'
    dirs.config = path.join temp, 'config/'
    
    for dir of dirs
      if path.existsSync(dirs[dir])
        rimraf.sync dirs[dir]
      fs.mkdirSync dirs[dir], 0777
        
    packer.save dirs, pack, opt, ->
       info = izpack.generateXML dirs, pack, opt # Todo: Run it through izpack compile, run it though converter utils
       cb()
      
