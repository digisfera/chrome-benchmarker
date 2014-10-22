#!/bin/bash
echo "console.timeStamp('testStart');setTimeout(function() { console.timeStamp('testEnd') }, 30);" | ./bin/chrome-benchmarker.js stdinJs