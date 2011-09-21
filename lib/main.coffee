log = require 'node-log'
log.setName 'npkg'
  
fs = require 'fs'
path = require 'path'
packer = require './packer'

module.exports = 
  # windows: require './windows/main'
  debian: require './debian/main'
  # osx: require './osx/main'
  
  build: (gen, opt) ->
      throw new Error 'Invalid generator' unless gen
      throw new Error 'Missing parameters' unless opt
      pack = JSON.parse fs.readFileSync path.join(opt.in, 'package.json')
      throw new Error 'Failed to find package.json in ' + opt.in unless pack
      throw new Error '"name" property not in package.json' unless pack.name
      
      log.info 'Starting ' + opt.arch + ' build'
      basedir = path.join '/temp/', opt.arch + pack.name + new Date().getTime(), '/'
      dirs = {}
      dirs.main = opt.in + '/'
      dirs.temp = basedir
      dirs.app = path.join basedir, 'app/'
      dirs.deps = path.join basedir, 'dependencies/'
      dirs.node = path.join basedir, 'node/'
      dirs.config = path.join basedir, 'configuration/'
      
      log.debug 'Temporary folder: ' + basedir
      path.mkDirSync dir for dir in dirs
        
      log.info 'Packing and grabbing dependencies...'
      packer.save dirs, pack, opt
          
      gen.builder.build dirs, pack, opt
      
