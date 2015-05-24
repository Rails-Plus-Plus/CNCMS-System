CoffeeScript = require "coffee-script"
fs = require "fs"

kernelCreated = false

class NotImplementedError
  constructor: (@msg) ->

  toString: () ->
    "NotImplementedError: #{@msg}"

class Kernel
  constructor: () ->
    throw new NotImplementedError "Attempt to construct a singleton class!" if kernelCreated

  createHookable: (name) ->
    throw new NotImplementedError "Kernel.createHookable - Not implemented."

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
    throw new NotImplementedError "Kernel.hook - Not implemented."

  load: (mname) ->
    delete require.cache[require.resolve mname]
    return require mname

  getSiteName: () ->
    "A CoffeeNode CMS site"

  getApp: (name) ->
    load(name + "/core")

  getPage: (url, post) ->
    content = ""
    if url == "/"
      content = [200, "<html>\n  <head>\n    <title>#{@getSiteName()} - Home</title>\n  </head>\n  <body>\n    <h1>Welcome to #{@getSiteName()}; the software which runs this site is not complete.</h1>\n    <p>If you are the site owner, please check the CoffeeNode CMS GitHub repository for updates. Please use other software while CoffeeNode CMS is in development.</p>\n  </body>\n</html>"]
    else if url.match(/\/app\/.+\/.*/)
      # TODO: Capture app name and page from URL here.
      throw new NotImplementedError "Applications are not implemented."
      app = @getApp appName
      content = app.page(page, post)
    else if fs.existsSync("../../" + url + ".js")
      page = require("../../" + url + ".js")
      content = page.get()
    else
      content = [404, "<html>\n  <head>\n    <title>#{@getSiteName()} - Error 404</title>\n  </head>\n  <body>\n    <h1>Error 404: Not found</h1>\n    <p>The Application or Page at #{url} could not be found.</p>\n  </body>\n</html>"]
    return content

module.exports = new Kernel
