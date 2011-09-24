jsxml = require 'jsontoxml'
path = require 'path'

module.exports =
  generateXML: (dirs, pack, opt, cb) ->
    app = {}
    
    # Install info - Displayed during install + used in saving files
    app.info =
      appname: pack.name
      appversion: pack.version
      url: pack.homepage
      author: pack.author
      requiresjdk: 'no'
      generator: 'npkg' # Shameless watermarking, this isnt displayed anywhere
    
    # Installer variables - TODO: Let devs have a config to change these via CLI 
    # Example - These can be used to automatically tick desktop shortcuts etc.
    app.variables = {}
    
    ### TODO: License file autofind, info from package.json, etc.
    app.resources = []
    app.resources.push res: {attrs: {id: 'InfoPanel.info', src=''}}
    ### 
    
    path.exists path.join(dirs.app, 'LICENSE'), (exists) ->
      app.panels = []
      app.resources = []
      app.packs = []
      app.panels.push name: 'panel', attrs: 'classname="HelloPanel"'
      if exists
        app.panels.push name: 'panel', attrs: 'classname="LicencePanel"'
        app.resources.push name: 'res', attrs: 'id="LicencePanel.licence" src="' + path.join(path.basename(dirs.app), 'LICENSE') + '"'
      app.panels.push name: 'panel', attrs: 'classname="TargetPanel"' 
      app.panels.push name: 'panel', attrs: 'classname="InstallPanel"' 
      app.panels.push name: 'panel', attrs: 'classname="SimpleFinishPanel"'
      # TODO: <executable> that sets up os-dependent shit and compiles node if it needs to
      mainpack = 
        name: 'pack'
        attrs: 'name="' + pack.name+  '" required="yes" preselected="yes" id="' + pack.name + '"'
      mainpack.children = [description: pack.description, name: 'file', attrs: 'src="' + dirs.temp + '" targetdir="$INSTALL_PATH" override="asktrue"']
      app.packs.push mainpack

      cb '<?xml version="1.0" encoding="iso-8859-1" standalone="yes" ?><installation version="1.0">' + jsxml.obj_to_xml(app) + '</installation>'
