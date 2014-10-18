url = require('url')
path = require('path')
minimist = require('minimist')
benchmarker = require('./index')

run = ->
  argv = minimist(process.argv.slice(2))

  target = argv['_'][0]
  options = argv

  if !target then return printUsage()

  benchmarkingFun = chooseFun(target)
  benchmarkingFun target, options, (err, success) ->
    if err then return console.error(err)
    if argv.json
      console.log success
    else 
      console.log "Memory: #{parseFloat(success.memory/1024).toFixed(2)}kB"
      console.log "Time: #{parseFloat(success.time).toFixed(2)}ms"

chooseFun = (target) ->
  targetUrl = url.parse(target)
  if targetUrl.host then benchmarker.url
  else if path.extname(target) in [ '.js' ] then benchmarker.js
  else if path.extname(target) in [ '.html', '.htm' ] then benchmarker.html
  else throw "Unknown target type: #{target}"

printUsage = () ->
  console.log "Usage:"
  console.log ""
  console.log "chrome-benchmarker.js target --json --useFun <url|js|html> --debuggingPort <port> --port <port> --host <host> --basePath <path>"
  console.log ""
  console.log "All arguments are optional except `target`"

module.exports = { run }

