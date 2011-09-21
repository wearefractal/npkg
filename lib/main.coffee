log = require 'node-log'
log.setName 'npkg'

rimraf = require 'rimraf'
fs = require 'fs'
path = require 'path'
packer = require './packer'

module.exports = 
  # windows: require './windows/main'
  debian: require './debian/main'
  # osx: require './osx/main'
  
  build: (temp, gen, opt, cb) ->
      return cb 'Invalid generator' unless gen
      return cb 'Missing parameters' unless opt
      pack = JSON.parse fs.readFileSync path.join(opt.in, 'package.json')
      return cb 'Failed to find package.json in ' + opt.in unless pack
      return cb '"name" property not in package.json' unless pack.name
      
      log.info 'Starting ' + opt.arch + ' build'
        
      base = path.join temp, 'npkg-' + opt.arch + pack.name + new Date().getTime(), '/'
      dirs = {}
      dirs.temp = temp
      dirs.base = base
      dirs.app = path.join base, 'app/'
      dirs.deps = path.join base, 'dependencies/'
      dirs.node = path.join base, 'node/'
      dirs.config = path.join base, 'configuration/'
      
      log.debug 'Temporary folder: ' + base
      for dir of dirs
        if path.existsSync(dirs[dir])
          rimraf.sync dirs[dir]
        fs.mkdirSync dirs[dir], 0777

      log.info 'Packing and grabbing dependencies...'
      packer.save dirs, pack, opt, (err) ->
        if err
          return cb err
        gen.builder.build dirs, pack, opt, cb # Todo: This is where writing of output files should be
      
