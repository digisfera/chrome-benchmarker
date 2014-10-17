serveStatic = require('serve-static')
finalhandler = require('finalhandler')
http = require('http')

launcher = require('browser-launcher')
Chrome = require('chrome-remote-interface')
_ = require('lodash')
path = require('path')

test = (htmlPath, opts, done) ->
  opts.basePath ?= path.dirname(htmlPath)
  opts.port ?= 8666
  opts.host ?= 'localhost'
  opts.debuggingPort ?= 9222

  relativeHtmlPath = path.relative(opts.basePath, htmlPath).split(path.sep).join('/')
  url = "http://#{opts.host}:#{opts.port}/#{relativeHtmlPath}"

  server = startServer(opts.basePath, opts.port)
  launchChrome url, opts.debuggingPort, (err, browser) ->
    #console.log "Browser launched"
    runTest url, opts.debuggingPort, (err, testResult) ->
      browser.kill()
      server.close()
      done(err, testResult)

startServer = (dir, port) ->
  serve = serveStatic(dir)
  server = http.createServer (req, res) ->
    serve(req, res, finalhandler(req, res))

  server.listen(port)
  server

launchChrome = (url, debuggingPort, done) ->
  launcher (err, launch) ->
    if err then return done(err)
    #console.dir(launch.browsers)
    launch(url, { browser: 'chrome', options: ["--remote-debugging-port=#{debuggingPort}"] }, done)

runTest = (url, port, done) ->
  Chrome { port }, (chrome) ->
    
    chrome.Timeline.start({ includeCounters: true })

    chrome.on 'Timeline.started', () ->
      chrome.Page.navigate({ url })

    chrome.on 'Timeline.eventRecorded', (evt) ->
      try
        testResult = processDebuggerEvent(evt)
      catch e
        return done(e)

      if testResult then done(null, testResult)


findDebuggerEventInTree = (evtRaw, f, results = []) ->
  evt = evtRaw?.record || evtRaw
  if f(evt) then results.push(evt)
  findDebuggerEventInTree(child, f, results) for child in (evt?.children ? [])
  results

findInTreeByType = (evt, eventType) -> findDebuggerEventInTree(evt, (e) -> e.type == eventType)


hasTestStarted = false
testData = {}

processDebuggerEvent = (rootEvt) ->
  countersEvents = findInTreeByType(rootEvt, 'UpdateCounters')
  gcEvents = findInTreeByType(rootEvt, 'GCEvent')
  timestampEvents = findInTreeByType(rootEvt, 'TimeStamp')

  if testStartEvent(timestampEvents)
    if hasTestStarted then throw 'Test started more than once'
    hasTestStarted = true
    testData.startTime = testStartEvent(timestampEvents)
    testData.startHeapUsage = getCurrentHeapUsage()
    #console.log "Let's go!", testData.startTime, testData.startHeapUsage

  processMemoryEvents(countersEvents, gcEvents)


  if testEndEvent(timestampEvents)
    if !hasTestStarted then throw 'Test ended before starting'
    testData.endTime = testEndEvent(timestampEvents)
    testData.endHeapUsage = getCurrentHeapUsage()
    #console.log "We're done!", testData.endTime
    return testResults(testData)
  else
    return false

countedGarbageCollection = 0
uncountedGarbageCollectorEvents = []
lastCountedHeapUsage = null
lastCounterEventTime = null
processMemoryEvents = (counters, gc) ->
  if counters?.length > 0
    #Update current Heap count
    lastCounterEvent = _.max counters, (evt) -> evt.startTime
    if !(lastCounterEvent.startTime > lastCounterEventTime)
      throw "Unordered events!"
    lastCounterEventTime = lastCounterEvent.startTime
    lastCountedHeapUsage = lastCounterEvent.data.jsHeapSizeUsed

  if gc?.length > 0
    #Update GC count
    #Uncounted events don't really seem to occur
    groupedGcEvents = _.groupBy gc, (evt) -> evt.endTime < lastCounterEventTime
    counted = groupedGcEvents.true ? []
    uncounted = groupedGcEvents.false ? []

    countedGarbageCollection += evt.data.usedHeapSizeDelta for evt in counted
    countedGarbageCollection += evt.data.usedHeapSizeDelta for evt in uncountedGarbageCollectorEvents when evt.data.endTime < lastCounterEventTime

    uncountedGarbageCollectorEvents.push(evt) for evt in uncounted

getCurrentHeapUsage = -> lastCountedHeapUsage + countedGarbageCollection

testStartEvent = (evts) ->
  startEvent = _.find evts, (evt) -> evt?.data?.message == 'testStart'
  startEvent?.startTime

testEndEvent = (evts) ->
  endEvent = _.find evts, (evt) -> evt?.data?.message == 'testEnd'
  endEvent?.startTime

testResults = (testData) ->
  time: testData.endTime - testData.startTime
  memory: testData.endHeapUsage - testData.startHeapUsage 

test 'test/test-garbage.html', {}, (err, success) ->
  console.log(err, success)