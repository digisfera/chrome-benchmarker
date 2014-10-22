# chrome-benchmarker

Benchmark memory allocation and execution time of browser code using the Chrome Debugger Protocol.

Useful when trying to write garbage free Javascript.

## Usage ##

### CLI ###

`$ npm install chrome-benchmarker`

Write a JavaScript file with the benchmark:

```js
console.timeStamp('startTest'); //Call before benchmark code
doSomeStuff();
console.timeStamp('endTest');  //Call after benchmark code
```

`$ chrome-benchmarker benchmark.js`

This will start an HTTP server to serve the code in benchmark.js, launch Chrome, connect to the Chrome remote debugging interface, collect and process the Timeline data and print the total allocated memory and execution time.

### Module ###

```js
benchmarker = require('chrome-benchmarker')
benchmarker.js('benchmark.js', function(err, result) {
  // result = { memory, time }
});
```

### HTML / Multiple files ###

It is possible to run benchmarks which require multiple scripts or other HTML code by using an HTML file:

```html
<html>
<body>
  <div id="someDomStuff"></div>
  <script type="text/javascript" src="someDependency.js"></script>
  <script type="text/javascript">
    console.timeStamp('startTest'); //Call before benchmark code
    doSomeStuff();
    console.timeStamp('endTest');  //Call after benchmark code
  </script>
</body>
</html>
```

`$ chrome-benchmarker benchmark.html`

In Node:

```js
benchmarker.html('benchmark.html', callback)
```

### Existing server ###

If the required file(s) are already being served, one can simply run the benchmark from their URL:

```
$ chrome-benchmarker http://localhost:3000/benchmark.html
$ chrome-benchmarker http://localhost:3000/benchmark.js
```

In Node:

```js
benchmarker.url('http://localhost:3000/benchmark.html', callback)
benchmarker.url('http://localhost:3000/benchmark.js', callback)
```

## Module API ##

### js(javascriptFilePath, [options], callback)

`javascriptFilePath` is a path to a JavaScript file with the code to be benchmarked. The code should call `console.timeStamp('startTest')` and `console.timeStamp('endTest')`.

`options` is an object with the following optional properties:

- `port`: Webserver port. Defaults to `8666`.
- `host`: Webserver host. Defaults to `localhost`.
- `debuggingPort`: Remote Debugging Protocol port. Defaults to `9222`.

`callback` gets the following arguments:

- `err`: a Error object indicating the success status.
- `result`: an object `{ memory, time }`.


### jsStream(javascriptStream, [options], callback)

Similar to `js()`, but receiving a stream instead of a file path


### jsSrc(javascriptSourceCode, [options], callback)

Similar to `js()`, but receiving source code instead of a file path


### html(mainHtmlFilePath, [options], callback)

`mainHtmlFilePath` is a path to an HTML file with the code to be benchmarked. This file may load other files. The code it executes should call `console.timeStamp('startTest')` and `console.timeStamp('endTest')`.

`options` is an object with the following optional properties:

- `basePath`: Webserver root path. Defaults to `path.dirname(mainHtmlFilePath)`.
- `port`: Webserver port. Defaults to `8666`.
- `host`: Webserver host. Defaults to `localhost`.
- `debuggingPort`: Remote Debugging Protocol port. Defaults to `9222`.

`callback` gets the following arguments:

- `err`: a Error object indicating the success status.
- `result`: an object `{ memory, time }`.


### url(url, [options], callback)

`url` is a URL to be benchmarked. The code it executes should call `console.timeStamp('startTest')` and `console.timeStamp('endTest')`.

`options` is an object with the following optional properties:

- `debuggingPort`: Remote Debugging Protocol port. Defaults to `9222`.

`callback` gets the following arguments:

- `err`: a Error object indicating the success status.
- `result`: an object `{ memory, time }`.


## CLI Options ##

`chrome-benchmarker.js target --json --useFun <url|js|html> --debuggingPort <port> --port <port> --host <host> --basePath <path>`

All arguments except `target` are optional.

If `target` is `stdinJs`, the Javascript source for the test will be read from the standard input.


## References ##

https://developer.chrome.com/devtools/docs/debugger-protocol

https://developer.chrome.com/devtools/docs/protocol/1.1/index 

https://code.google.com/p/chromium/codesearch#chromium/src/third_party/WebKit/Source/devtools/protocol.json&q=protocol.json&sq=package:chromium&type=cs

http://buildnewgames.com/garbage-collector-friendly-code/


## Known issues ##

Sometimes there is a `ECONNREFUSED` error