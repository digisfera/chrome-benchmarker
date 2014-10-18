async = require('async')
benchmarker = require('../../src/index')

async.mapSeries [ 'immediate.html', 'timeout.html', 'domcontentloaded.html', 'both.html' ], benchmarker.html.bind(null), (err, results) ->
  console.log err, results
