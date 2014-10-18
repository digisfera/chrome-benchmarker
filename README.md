Benchmark execution time and memory usage of browser code using the Chrome Debugger Protocol.

Useful when writing garbage free Javascript.

## Usage ##
   
    benchmarker = require('chrome-benchmarker')
    
    benchmarker.js(jsFilePath, opts, done)
    benchmarker.html(htmlFilePath, opts, done)
    benchmarker.url(url, opts, done)

## References ##

https://developer.chrome.com/devtools/docs/debugger-protocol

https://developer.chrome.com/devtools/docs/protocol/1.1/index 

https://code.google.com/p/chromium/codesearch#chromium/src/third_party/WebKit/Source/devtools/protocol.json&q=protocol.json&sq=package:chromium&type=cs

http://buildnewgames.com/garbage-collector-friendly-code/

## To do ##

Options on `benchmarker.js()` to automatically add `setTimeout()` and `console.timeStamp()` to the Javascript code.