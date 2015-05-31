chai = require "chai"
chai.should()
require "../src/cms/System/Kernel"

describe "Kernel", ->
  it

  code = """
  class Hello
    constructor: () ->
      @msg = "Hello, world!"

    get: () ->
      @msg

    set: (val) ->
      @msg = val
  """
  appConfig = {
    "appName": "Hello"
    "authors": ["Alex Martin"]
    "version": 1.0
    "description": "A test app."
    "mainClass": "Hello"
    "classes": {
      "Hello": {
        "source": "Hello.coffee"
        "compiled": "Hello.js"
        "precompiled": false
        "authors": ["Alex Martin"]
        "version": 1.0
        "description": "A test class."
        "since": 1.0
        "static": false
      }
    }
  }
  codePreProcessed = """
  class Hello
    constructor: () ->
      @msg = "Hello, world!"

    get: () ->
      Kernel.fireHookable "Hello.get"
      @msg

    set: (val) ->
      Kernel.fireHookable "Hello.set", val
      @msg = val
  """
  page404 = "<html>\n  <head>\n    <title>#{@getSiteName()} - Error 404</title>\n  </head>\n  <body>\n    <h1>Error 404: Not found</h1>\n    <p>The Application or Page at #{url} could not be found.</p>\n  </body>\n</html>"

  it "should exist", ->
    should.exist Kernel

  it "should be able to preprocess code", ->
    Kernel.preprocess(code, appConfig).should.equal codePreProcessed

  it "should return a 404 page for non-existant pages", ->
    Kernel.getPage("/doesnotexistorifitdoesthatsweird").should.equal page404
