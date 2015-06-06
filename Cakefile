CoffeeScript = require "coffee-script"
fs = require "fs"
util = require "util"
spawn = require("child_process").spawn

system = (command, args, callback) ->
  output = ""
  console.log "#{command} #{args}"
  child = spawn process.env.SHELL, ["-c", "#{command} #{args}"], {
    "cwd": process.cwd
    "env": process.env
  }
  code = null;

  child.stdout.on "data", (data) ->
    console.log "" + data

  child.stderr.on "data", (data) ->
    console.log "" + data

  child.on "close", (res) ->
    console.log "#{command} exited with code #{res}."
    code = res

  wait = () ->
    if not code?
      setTimeout wait, 1
    else
      callback code if callback?

  wait()

compile = (source) ->
  system "coffee", "-c #{source}"

option "-h", "--hostname [HOSTNAME]", "Specify a hostname to listen on when running"
option "-p", "--port [PORT]", "Specify a port to listen on when running"
option "-T", "--test [OPTION]", "Specify options for tests."

task "compile:src/server.js", "Build the CoffeeNode CMS HTTP server", (options) ->
  throw "Missing source file src/server.coffee!" if not fs.existsSync "src/server.coffee"
  compile "src/server.coffee"

task "compile:src/cms/System/Kernel.js", "Build the CoffeeNode CMS Kernel", (options) ->
  throw "Missing source file src/cms/System/Kernel.coffee!" if not fs.existsSync "src/cms/System/Kernel.coffee"
  compile "src/cms/System/Kernel.coffee"

task "compile", "Compile CoffeeNode CMS CoffeeScript files to JS", (options) ->
  invoke "compile:src/cms/System/Kernel.js"
  invoke "compile:src/server.js"

task "build", "Build CoffeeNode CMS to production usability", (options) ->
  invoke "compile"

task "clean", "Remove build products", (options) ->
  system "rm", "server.js"
  system "rm", "cms/System/Kernel.js"

task "test", "Do a test of the System using Mocha", (options) ->
  system "mocha", "--compilers coffee:coffee-script/register -R spec", (code) ->
    process.exit code

task "run", "Compile CoffeeNode CMS and run the HTTP server", (options) ->
  invoke "compile"
  `setTimeout(function() {
    system("node", "server.js " + options.hostname + " " + options.port)
  }, 1500)` # Wait 1.5 seconds for compilation to finish.
