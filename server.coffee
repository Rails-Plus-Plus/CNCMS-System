try
  Kernel = require "./cms/System/Kernel" # Only needed once, in the server/index page.
  http = require "http"
  url = require "url"

  port = parseInt process.argv[3]
  host = process.argv[2]

  errorMsg = "Sorry, an internal error occurred. Error information: "

  # Here we set up an HTTP server to call Kernel.getPage() and send it to the client.
  server = http.createServer (request, response) ->
    try
      requestURL = url.parse request.url # Get and parse request URL.
      console.log "#{new Date()}: Got a request for #{requestURL.pathname}."
      console.log "#{new Date()}: Asking Kernel for page for #{requestURL.pathname}..."
      [code, content] = Kernel.getPage requestURL.pathname # Ask Kernel for the page.
      console.log "#{new Date()}: Got page and code (#{code}) for #{requestURL.pathname}. Sending headers..."
      response.writeHead code, { # Send the page to the client.
        "content-length": content.length
        "content-type": "text/html"
      }
      console.log "#{new Date()}: Headers sent for #{requestURL.pathname}."
      response.end content
      console.log "#{new Date()}: Content sent for #{requestURL.pathname}. Done with request."
      return true
    catch error
      console.log "#{new Date()}: Exception thrown while handling request. Exception is a #{error}"
      console.log "#{new Date()}: Sending 500 error headers..."
      response.writeHead 500, { # Send the error to the client.
        "content-length": errorMsg.length + error.toString().length,
        "content-type": "text/plain"
      }
      console.log "#{new Date()}: Sending 500 page..."
      response.end errorMsg + error.toString()
      console.log "#{new Date()}: Done with error."
      return false

  try
    console.log "Detected running directly in CoffeeScript! Cool!" if process.argv[0] == "coffee"
    console.log "#{new Date()}: Setting up HTTP server on #{host}:#{port}..."
    Kernel.onIdle()
    server.listen(port, host)
  catch error
    console.log "Could not start server! #{error}"
catch error
  console.error "Crashed with uncaught exception: #{error}"
