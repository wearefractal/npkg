jsxml = require 'jsontoxml'
path = require 'path'
exec = require('child_process').exec
log = require 'node-log'

# Super lame way of removing bullshit from package. Fuckers dont know how to leave out < and >
filter = (str) ->
  str = str.replaceAll '<', '&lt;'
  str = str.replaceAll '>', '&gt;'
  
module.exports =
  # Turns our install.xml into install.jar
  compile: (dirs, pack, opt, cb) ->
    log.info 'Compiling installer...'
    cmd = __dirname + '/izpack/bin/compile "' + path.join(dirs.config, 'install.xml') + '" -b "' + dirs.temp + '" '
    cmd += '-o "' + path.join(opt.out, 'install.jar') + '" -k standard'
    exec cmd, (error, stdout, stderr) ->
      throw error if error
      cb()
        
  # This is a trainwreck of converting a JSON object to XML
  generateXML: (dirs, pack, opt, cb) ->
    log.info 'Generating installer configuration...'
    app = {}
    
    # Install info - Displayed during install + used in saving files
    app.info =
      appname: filter pack.name
      appversion: filter pack.version
      url: filter pack.homepage
      author: filter pack.author
      requiresjdk: 'no'
      generator: 'npkg' # Shameless watermarking, this isnt displayed anywhere
    
    app.locale = [name: 'langpack', attrs: 'iso3="eng"']
    
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
        attrs: 'name="' + pack.name +  '" required="yes" preselected="yes" id="' + pack.name + '"'
        
      mainpack.children = [{name: 'description', text: filter(pack.description)}, 
          {name: 'file', attrs: 'src="' + dirs.temp + '" targetdir="$INSTALL_PATH" override="asktrue"'}]
      app.packs.push mainpack

      cb '<?xml version="1.0" encoding="iso-8859-1" standalone="yes" ?><installation version="1.0">' + jsxml.obj_to_xml(app) + '<guiprefs resizable="yes" width="800" height="600"/></installation>'
