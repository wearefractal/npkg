jsxml = require 'jsontoxml'

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
      createdBy: 'npkg' # Shameless watermarking, this isnt displayed anywhere
    
    # Installer variables - TODO: Let devs have a config to change these via CLI 
    # Example - These can be used to automatically tick desktop shortcuts etc.
    app.variables = {}
    
    ### TODO: License file autofind, info from package.json, etc.
    app.resources = []
    app.resources.push res: {attrs: {id: 'InfoPanel.info', src=''}}
    ### 
    
    app.panels = []
    app.panels.push {name: 'panel', attrs: 'classname="HelloPanel"'}  
    app.panels.push {name: 'panel', attrs: 'classname="TargetPanel"'}  
    app.panels.push {name: 'panel', attrs: 'classname="InstallPanel"'}  
    app.panels.push {name: 'panel', attrs: 'classname="SimpleFinishPanel"'}  
    return '<installation version="1.0">' + jsxml.obj_to_xml(app) + '</installation>'
