npm = require './npm'

module.exports =
  save: (dirs, pack, cb) ->
    deps = npm.resolve dirs.main
