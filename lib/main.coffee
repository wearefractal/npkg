require('node-log').setName 'node-package'

module.exports = 
  windows = require './windows/main'
  unix = require './unix/main'
  osx = require './osx/main'
