CoffeeScript = require "coffee-script"
spawn = require "child_process"
fs = require "fs"

kernelCreated = false

class NotImplementedError
  constructor: (@msg) ->

  toString: () ->
    "NotImplementedError: #{@msg}"

class Kernel
  hooks = {}

  constructor: () ->
    throw new NotImplementedError "Attempt to construct a singleton class!" if kernelCreated

  createHookable: (name) ->
    @hooks[name] = {}

  runCmd: (command, args, sync) ->
    output = ""
    done = false
    console.log "#{command} #{args}"
    child = spawn process.env.SHELL, ["-c", "#{command} #{args}"], {
      "cwd": process.cwd
      "env": process.env
    }

    child.stdout.on "data", (data) ->
      console.log "" + data

    child.stderr.on "data", (data) ->
      console.log "" + data

    child.on "close", (code) ->
      console.log "#{command} exited with code #{code}."
      done = true

    if sync
      (->) until done
    return output

  hook: (hookName, callback) ->
    @hooks[hookName].append callback

  preprocess: (code) ->
    throw new NotImplementedError "Kernel.preprocess - Not implemented."

  load: (mname) ->
    mloc = "../#{mname}"
    delete require.cache[require.resolve mloc]
    return require mloc

  getSiteName: () ->
    "A CoffeeNode CMS site"

  getApp: (name) ->
    appConfig = @load "../#{name}/app"
    @load "#{name}/#{appConfig.mainClass}"

  getPage: (url, post) ->
    content = ""
    if url == "/"
      content = [200, "<html>\n  <head>\n    <title>#{@getSiteName()} - Home</title>\n  </head>\n  <body>\n    <h1>Welcome to #{@getSiteName()}; the software which runs this site is not complete.</h1>\n    <p>If you are the site owner, please check the CoffeeNode CMS GitHub repository for updates. Please use other software while CoffeeNode CMS is in development.</p>\n  </body>\n</html>"]
    else if url.match /\/app\/.+\/.*/
      urlMatchResults = url.match /\/app\/(.+)\/.*/
      appName = urlMatchResults[1]
      app = @getApp appName
      content = app.get(url, post)
    else if fs.existsSync("../../" + url + ".js")
      page = require("../../" + url + ".js")
      content = page.get()
    else
      content = [404, "<html>\n  <head>\n    <title>#{@getSiteName()} - Error 404</title>\n  </head>\n  <body>\n    <h1>Error 404: Not found</h1>\n    <p>The Application or Page at #{url} could not be found.</p>\n  </body>\n</html>"]
    return content

module.exports = new Kernel
