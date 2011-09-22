log = require 'node-log'
log.setName 'npkg'

rimraf = require 'rimraf'
fs = require 'fs'
path = require 'path'
packer = require './packer'
izpack = require './izpack'

module.exports = 
  build: (temp, opt, cb) ->
      return cb 'Missing parameters' unless opt
      pack = JSON.parse fs.readFileSync path.join(opt.in, 'package.json')
      return cb 'Failed to find package.json in ' + opt.in unless pack
      return cb '"name" property not in package.json' unless pack.name
      
      log.info 'Starting ' + pack.name + ' build'
        
      base = path.join temp, 'npkg-' + pack.name + new Date().getTime(), '/'
      dirs = {}
      dirs.temp = temp
      dirs.base = base
      dirs.app = base
      dirs.node = path.join base, 'node/'
      dirs.deps = path.join dirs.node, 'node_modules/'
      dirs.config = path.join base, 'config/'
      
      log.debug 'Temporary folder: ' + base
      for dir of dirs
        if path.existsSync(dirs[dir])
          rimraf.sync dirs[dir]
        fs.mkdirSync dirs[dir], 0777

      log.info 'Packing and grabbing dependencies...'
      packer.save dirs, pack, opt, (err) ->
         return cb err if err
         log.debug izpack.generateXML dirs, pack, opt, cb # Todo: Gen XML installer from package.json, run it through izpack compile, run it though converter utils
      
