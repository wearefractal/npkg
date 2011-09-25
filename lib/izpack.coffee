path = require 'path'
fs = require 'fs'
exec = require('child_process').exec
log = require 'node-log'
async = require 'async'
npm = require './npm'
  
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
        fs.chmod outjar, 0777, (err) ->
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

    # Install info - Displayed during install + used in saving files
    authors = []
    authors.push pack.author
    if pack.contributors then authors.merge pack.contributors
    if pack.maintainers then authors.merge pack.maintainers
    authors = (npm.parsePerson(author) for author in authors)
    # Header    
    out = '<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>'
    out += '<installation version="1.0">' 

    # Main info - present on the UI
    out += '<info>'
    out += '<appname>' + pack.name + '</appname>'
    out += '<appversion>' + pack.version + '</appversion>'
    out += '<url>' + (pack.homepage || author.url) + '</url>'
    out += '<requiresjdk>no</requiresjdk>'
    out += '<authors>'
    out += '<author name="' + author.name + '" email="' + author.email + '"/>' for author in authors # <3 coffeescript
    out += '</authors>'
    out += '<npkg/>' # Shameless watermarking, this isnt displayed anywhere
    out += '<pack200/>' # Turns 40mb into 9mb. o lawd is dat sum insurgency
    out += '</info>'

    # UI panels
    out += '<panels>'
    out += '<panel classname="HelloPanel"/>'
    licensed = path.existsSync path.join dirs.app, 'LICENSE'
    if licensed then out += '<panel classname="LicencePanel"/>'
    out += '<panel classname="TargetPanel"/>'
    out += '<panel classname="InstallPanel"/>'
    out += '<panel classname="ProcessPanel"/>'
    out += '<panel classname="SimpleFinishPanel"/>'
    out += '</panels>'

    # Resources for the panels
    out += '<resources>'
    out += '<res id="ProcessPanel.Spec.xml" src="' + path.join(path.basename(dirs.config), 'PostInstall.xml') + '"/>'
    if licensed then out += '<res id="LicencePanel.licence" src="' + path.join(path.basename(dirs.app), 'LICENSE') + '"/>'
    out += '</resources>'
    
    # Application files
    out += '<packs>'
    out += '<pack name="' + pack.name + '" required="yes">'
    out += '<description>' + pack.description + '</description>'
    out += '<fileset dir="' + dirs.temp + '" targetdir="$INSTALL_PATH" override="true"/>'
    out += '<executable targetfile="$INSTALL_PATH/config/unix.sh" stage="never" keep="true"/>'
    out += '</pack>'
    out += '</packs>'
    
    # Constants
    out += '<guiprefs resizable="yes" width="600" height="400"/>'
    out += '<locale><langpack iso3="eng"/></locale>' # Shortcuts on windows
    out += '<natives><native type="izpack" name="ShellLink.dll"/></natives>' # Shortcuts on windows
    out += '</installation>'
    cb out
