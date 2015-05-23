CoffeeScript = require "coffee-script"
fs = require "fs"
util = require "util"
spawn = require("child_process").spawn

system = (command, args, sync) ->
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

compile = (source) ->
  system "coffee", "-c #{source}"

option "-h", "--hostname [HOSTNAME]", "Specify a hostname to listen on when running"
option "-p", "--port [PORT]", "Specify a port to listen on when running"

task "compile:server.js", "Build the CoffeeNode CMS HTTP server", (options) ->
  throw "Missing source file server.coffee!" if not fs.existsSync "server.coffee"
  compile "server.coffee", true

task "compile:cms/System/Kernel.js", "Build the CoffeeNode CMS Kernel", (options) ->
  throw "Missing source file cms/System/Kernel.coffee!" if not fs.existsSync "cms/System/Kernel.coffee"
  compile "cms/System/Kernel.coffee", true

task "compile", "Compile CoffeeNode CMS CoffeeScript files to JS", (options) ->
  invoke "compile:cms/System/Kernel.js"
  invoke "compile:server.js"

task "clean", "Remove build products", (options) ->
  system "rm", "server.js", true
  system "rm", "cms/System/Kernel.js", true

task "run", "Compile CoffeeNode CMS and run the HTTP server", (options) ->
  invoke "compile"
  `setTimeout(function() {
    system("node", "server.js " + options.hostname + " " + options.port, false)
  }, 1500)` # Wait 1.5 seconds for compilation to finish.
