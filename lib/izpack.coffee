jsxml = require 'jsontoxml'
path = require 'path'
exec = require('child_process').exec
log = require 'node-log'
async = require 'async'
npm = require './npm'

# Super lame way of removing bullshit from package. Fuskers dont know how to leave out < and >
filter = (str) ->
  str = str.replaceAll '<', '&lt;'
  str = str.replaceAll '>', '&gt;'
  
module.exports =
  # Turns our install.xml into install.jar
  compile: (dirs, pack, opt, cb) ->    
    outjar = path.join opt.out, pack.name + '.jar'  
    outexe = path.join opt.out, pack.name + '.exe'
    outapp = path.join opt.out, pack.name + '.app'
    
    izdir = path.join __dirname, 'izpack'
    wrapdir = path.join izdir, '/utils/wrappers'
    
    jar = (call) ->
      log.info 'Compiling .jar installer...'
      cmd = path.join(izdir, '/bin/compile') + ' "' + path.join(dirs.config, 'install.xml') + '" -b "' + dirs.temp + '" -o "' + outjar + '" -k standard'
      exec cmd, (error, stdout, stderr) ->
        throw error if error
        call()
          
    exe = (call) ->
      log.info 'Compiling .exe installer...'
      cmd = path.join(wrapdir, '/izpack2exe/izpack2exe.py') + ' --file=' + outjar + ' --output=' + outexe 
      cmd += ' --with-7z=' + path.join(wrapdir, '/izpack2exe/7za') + ' --with-upx=' + path.join(wrapdir, '/izpack2exe/upx') # Options. TODO: Let user change these
      exec cmd, (error, stdout, stderr) ->
        throw error if error
        call()
    
    app = (call) ->
      log.info 'Compiling .app installer...'
      cmd = wrapdir + '/izpack2app/izpack2app.py ' + outjar + ' ' + outapp
      exec cmd, (error, stdout, stderr) ->
        throw error if error
        call()
                
    jar -> async.parallel [exe, app], cb
        
  # This is a trainwreck of converting a JSON object to XML
  generateXML: (dirs, pack, opt, cb) ->
    log.info 'Generating installer configuration...'
    app = {}
    
    # Install info - Displayed during install + used in saving files
    author = npm.parsePerson pack.author
    app.info =
      appname: filter pack.name
      appversion: filter pack.version
      url: pack.homepage || author.url
      authors: [{name: 'author', attrs: 'name="' + filter author.name + '" email="' + filter author.email + '"'}]
      requiresjdk: 'no'
      generator: 'npkg' # Shameless watermarking, this isnt displayed anywhere
      pack200: {}
    
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
          {name: 'file', attrs: 'src="' + dirs.temp + '" targetdir="$INSTALL_PATH" override="true"'}]
      app.packs.push mainpack

      cb '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?><installation version="1.0">' + jsxml.obj_to_xml(app) + '<guiprefs resizable="yes" width="800" height="600"/></installation>'
