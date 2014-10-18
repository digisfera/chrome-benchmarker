serveStatic = require('serve-static')
finalhandler = require('finalhandler')
http = require('http')

launcher = require('browser-launcher')
path = require('path')
fs = require('fs')
_ = require('lodash')

runTest = require('./runTest')
jsTestTemplate = require('./jsTestTemplate')

benchmarkUrl = (url, opts, done) ->
  opts.debuggingPort ?= 9222
  launchChrome url, opts.debuggingPort, (err, browser) ->
    runTest url, opts.debuggingPort, (err, testResult) ->
      done(err, testResult)
      browser.kill()

      

benchmarkHtml = (htmlPath, opts, done) ->
  if _.isFunction(opts) && !done?
    done = opts
    opts = {}

  opts.basePath ?= path.dirname(htmlPath)
  relativeHtmlPath = path.relative(opts.basePath, htmlPath).split(path.sep).join('/')

  server = http.createServer (req, res) ->
    serveStatic(opts.basePath)(req, res, finalhandler(req, res))

  benchmarkWithServer(server, opts, relativeHtmlPath, done)

benchmarkJs = (jsPath, opts, done) ->
  if _.isFunction(opts) && !done?
    done = opts
    opts = {}

  fs.readFile jsPath, (err, src) ->
    if err then return done(err)
    server = http.createServer (req, res) ->
      res.writeHead(200, {"Content-Type": "text/html"})
      res.end(jsTestTemplate(src))

    benchmarkWithServer(server, opts, '', done)

benchmarkWithServer = (server, opts, endpoint, done) ->
  opts.port ?= 8666
  opts.host ?= 'localhost'

  url = "http://#{opts.host}:#{opts.port}/#{endpoint}"

  server.listen opts.port, null, null, (err, success) ->
    if err then return done(err)
    benchmarkUrl url, opts, (err, testResult) ->
      try server.close()
      done(err, testResult)

launchChrome = (url, debuggingPort, done) ->
  launcher (err, launch) ->
    if err then return done(err)
    #console.dir(launch.browsers)
    launch(url, { browser: 'chrome', options: ["--remote-debugging-port=#{debuggingPort}"] }, done)

module.exports = { url: benchmarkUrl, html: benchmarkHtml, js: benchmarkJs }