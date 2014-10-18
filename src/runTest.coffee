Chrome = require('chrome-remote-interface')
_ = require('lodash')


runTest = (url, port, doneFun) ->
  done = _.once(doneFun)

  benchmark = new Benchmark()

  chooseTab = (tabs) ->
    _(tabs).findIndex((t) -> t.url == url)

  chromeConnection = Chrome({ port, chooseTab })
  chromeConnection.on('error', done)
  chromeConnection.on 'connect', (chrome) ->  
    chrome.Timeline.start({ includeCounters: true })

    chrome.on 'Timeline.started', () ->
      chrome.Page.navigate({ url })

    chrome.on 'Timeline.eventRecorded', (evt) ->
      try
        benchmark.processTimelineEvent(evt)
      catch e
        return done(e)

      if benchmark.completed
        chrome.close()
        done(null, benchmark.results())

class Benchmark
  constructor: () ->
    @started = false
    @completed = false
    @testData = {}
    @countedGarbageCollection = 0
    @uncountedGarbageCollectorEvents = []
    @lastCountedHeapUsage = null
    @lastCountersEventTime = null

  processTimelineEvent: (rootEvt) ->
    if @completed then return false

    countersEvents = findInTreeByType(rootEvt, 'UpdateCounters')
    gcEvents = findInTreeByType(rootEvt, 'GCEvent')
    timestampEvents = findInTreeByType(rootEvt, 'TimeStamp')

    timestampData = extractTimestampData(timestampEvents)

    if timestampData.start
      if @started then throw 'Test started more than once'
      @started = true
      @testData.startTime = timestampData.start.time
      @testData.startHeapUsage = @currentHeapUsage()
      #console.log "Let's go!", @testData.startTime, @testData.startHeapUsage

    @processMemoryEvents(countersEvents, gcEvents)

    if timestampData.end
      if !@started then throw 'Test ended before starting'
      @testData.endTime = timestampData.end.time
      @testData.endHeapUsage = @currentHeapUsage()
      #console.log "We're done!", @testData.endTime
      @completed = true

    return true

  processMemoryEvents: (counters = [], gc = []) ->
    #Update current Heap count
    lastCountersEvent = _.max(counters, (evt) -> evt.startTime)
    if lastCountersEvent == -Infinity then lastCountersEvent = null

    if lastCountersEvent
      if @lastCountersEventTime && !(lastCountersEvent.startTime > @lastCountersEventTime)
        throw new Error("Unordered events")
      @lastCountersEventTime = lastCountersEvent.startTime
      @lastCountedHeapUsage = lastCountersEvent.data.jsHeapSizeUsed

    #Update GC count
    #Process also previously uncounted events
    #Uncounted events don't really seem to occur
    gcEventsToProcess = Array.prototype.concat(gc, @uncountedGarbageCollectorEvents)

    groupedGcEvents = _.groupBy gcEventsToProcess, (evt) -> evt.endTime < @lastCountersEventTime
    counted = groupedGcEvents.true ? []
    uncounted = groupedGcEvents.false ? []

    @countedGarbageCollection += evt.data.usedHeapSizeDelta for evt in counted
    @uncountedGarbageCollectorEvents = uncounted

  currentHeapUsage: ->
    @lastCountedHeapUsage + @countedGarbageCollection

  results: ->
    if @completed
      time: @testData.endTime - @testData.startTime
      memory: @testData.endHeapUsage - @testData.startHeapUsage 
    else
      null


findDebuggerEventInTree = (evtRaw, f, results = []) ->
  evt = evtRaw?.record || evtRaw
  if f(evt) then results.push(evt)
  findDebuggerEventInTree(child, f, results) for child in (evt?.children ? [])
  results

findInTreeByType = (evt, eventType) -> findDebuggerEventInTree(evt, (e) -> e.type == eventType)

extractTimestampData = (evts) ->
  findEventWithMessage = (message) ->
    evt = _.find(evts, (evt) -> evt?.data?.message == message)
    if evt then { message, time: evt.startTime }
    else null

  {
    start: findEventWithMessage('testStart')
    end: findEventWithMessage('testEnd')
  }


module.exports = runTest