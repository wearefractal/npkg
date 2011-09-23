path = require 'path'
log = require 'node-log'
fs = require 'fs'
exec = require('child_process').exec

module.exports =
  unpack: (inf, out, striptop, cb) ->
    cmd = 'tar -xvzf ' + inf + ' -C ' + out
    if striptop then cmd += ' --strip 1'
    exec cmd, (err, stdout, stderr) ->
      cb(err || stderr)
