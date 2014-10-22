assert = require('chai').assert
benchmarker = require('../src/index')
fs = require('fs')

suite 'chrome-benchmarker', ->

  suite 'html()', ->

    test 'simple', (done) ->
      benchmarker.html "#{__dirname}/files/basic.html", {}, (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

    test 'omit options', (done) ->
      benchmarker.html "#{__dirname}/files/basic.html", (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

    test 'all options', (done) ->
      opts = 
        basePath: '.'
        port: 8667
        host: '127.0.0.1'
        debuggingPort: 9223

      benchmarker.html "#{__dirname}/files/basic.html", opts, (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

  suite 'js()', ->

    test 'simple', (done) ->
      benchmarker.js "#{__dirname}/files/basic.js", {}, (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

    test 'omit options', (done) ->
      benchmarker.js "#{__dirname}/files/basic.js", (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

    test 'all options', (done) ->
      opts = 
        port: 8667
        host: '127.0.0.1'
        debuggingPort: 9223

      benchmarker.js "#{__dirname}/files/basic.js", opts, (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

  suite 'jsStream', ->
    test 'simple', (done) ->
      stream = fs.createReadStream("#{__dirname}/files/basic.js")
      benchmarker.jsStream stream, {}, (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

  suite 'jsSrc()', ->
    test 'simple', (done) ->
      src = fs.readFileSync("#{__dirname}/files/basic.js")
      benchmarker.jsSrc src, {}, (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        done()

  suite 'results', ->

    #Memory usage is detected when a test is executed without setTimeout
    test 'nothing', (done) ->
      benchmarker.js "#{__dirname}/files/nothing.js", (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        assert(result.time < 50, 'Unexpected time: #{result.time}')
        assert(result.memory < 1024*200, 'Unexpected memory usage: #{result.memory}')
        #console.log result
        done()

    test 'garbage', (done) ->
      benchmarker.js "#{__dirname}/files/garbage.js", (err, result) ->
        assert.notOk(err)
        assert.ok(result)
        assert(1024*1024*5 < result.memory < 1024*1024*100 , 'Unexpected memory usage: #{result.memory}')
        #console.log result
        done()
