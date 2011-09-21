fs = require 'fs'
path = require 'path'

default =
  obfuscation: false

file = 'config.json'
if path.existsSync file
  module.exports = JSON.parse fs.readFileSync file
else
  module.exports = defaults
