CoffeeScript = require "coffee-script"
spawn = require "child_process".spawn
fs = require "fs"

kernelCreated = false

class NotImplementedError extends Error
  constructor: (@msg) ->

  toString: () ->
    "NotImplementedError: #{@msg}"

class Kernel
  hooks = {}
  idleJobs = []

  constructor: ->
    throw new Error "Attempt to construct a singleton class!" if kernelCreated

  createHookable: (name) ->
    @hooks[name] = {}

  runCmd: (command, args, print, callback) ->
    output = ""
    console.log "#{command} #{args}" if print
    child = spawn process.env.SHELL, ["-c", "#{command} #{args}"], {
      "cwd": process.cwd
      "env": process.env
    }

    child.stdout.on "data", (data) ->
      console.log "#{command} #{args}: #{data}" if print

    child.stderr.on "data", (data) ->
      console.log "#{command} #{args}: #{data}" if print

    child.on "close", (code) ->
      callback output, code

  hook: (hookName, callback) ->
    @hooks[hookName].push callback

  preprocess: (code) ->
    throw new NotImplementedError "Kernel.preprocess - Not implemented."

  load: (mname) ->
    mloc = "../#{mname}"
    delete require.cache[require.resolve mloc]
    return require mloc

  getSiteName: ->
    "A CoffeeNode CMS site"

  getApp: (name) ->
    console.log "#{new Date()}: Getting app config for '#{name}'..."
    appConfig = @load "#{name}/app"
    console.log "#{new Date()}: Loading #{appConfig.mainClass}..."
    @load "#{name}/#{appConfig.mainClass}"

  getPage: (url, post) ->
    content = ""
    if url == "/"
      content = [200, "<html>\n  <head>\n    <title>#{@getSiteName()} - Home</title>\n  </head>\n  <body>\n    <h1>Welcome to #{@getSiteName()}; the software which runs this site is not complete.</h1>\n    <p>If you are the site owner, please check the CoffeeNode CMS GitHub repository for updates. Please use other software while CoffeeNode CMS is in development.</p>\n  </body>\n</html>"]
    else if url.match /\/app\/.+\/.*/
      urlMatchResults = url.match /\/app\/(.+)\/.*/
      appName = urlMatchResults[1]
      console.log "#{new Date()}: Getting app '#{appName}'..."
      app = @getApp appName
      content = app.get(url, post)
    else if fs.existsSync("../../" + url + ".js")
      page = require("../../" + url + ".js")
      content = page.get()
    else
      content = [404, "<html>\n  <head>\n    <title>#{@getSiteName()} - Error 404</title>\n  </head>\n  <body>\n    <h1>Error 404: Not found</h1>\n    <p>The Application or Page at #{url} could not be found.</p>\n  </body>\n</html>"]
    return content

  addIdleJob: (callback, args...) ->
    idleJobs.push {callback, args}

  onIdle: =>
    job = idleJobs.shift()
    job[0](job[1]...) if job?


module.exports = new Kernel
