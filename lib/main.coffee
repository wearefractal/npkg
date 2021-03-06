require('coffee-script');
require 'protege'
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

    try
      pack = JSON.parse fs.readFileSync path.join(opt.in, 'package.json')
    catch err
      throw 'Failed to find package.json in ' + opt.in

    throw '"main" property not in package.json' unless pack.main
    throw '"author" property not in package.json' unless pack.author
    throw '"name" property not in package.json' unless pack.name

    log.info 'Starting ' + pack.name + ' build'
    dirs = {}
    dirs.temp = temp
    dirs.app = path.join temp, 'app/'
    dirs.node = path.join temp, 'node/'
    dirs.deps = path.join temp, 'deps/'
    dirs.npm = path.join dirs.node, 'node_modules/'
    dirs.config = path.join temp, 'config/'

    for dir of dirs
      if path.existsSync(dirs[dir])
        rimraf.sync dirs[dir]
      fs.mkdirSync dirs[dir], 0755

    if path.existsSync opt.out
      if fs.readdirSync(opt.out).length <= 3 # We create 3 files, if they have any more throw an error
        rimraf.sync opt.out
        fs.mkdirSync opt.out, 0755
      else
        console.error 'Detected an unclean build folder! Please specify an empty or nonexistant folder'
        return cb()
    else
      fs.mkdirSync opt.out, 0755

    packer.save dirs, pack, opt, ->
      izpack.generateXML dirs, pack, opt, (result) ->
        fs.writeFile path.join(dirs.config, 'install.xml'), result, (err) ->
          throw err if err
          izpack.compile dirs, pack, opt, cb

