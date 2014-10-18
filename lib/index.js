// Generated by CoffeeScript 1.8.0
(function() {
  var benchmarkHtml, benchmarkJs, benchmarkUrl, benchmarkWithServer, finalhandler, fs, http, jsTestTemplate, launchChrome, launcher, path, runTest, serveStatic, _;

  serveStatic = require('serve-static');

  finalhandler = require('finalhandler');

  http = require('http');

  launcher = require('browser-launcher');

  path = require('path');

  fs = require('fs');

  _ = require('lodash');

  runTest = require('./runTest');

  jsTestTemplate = require('./jsTestTemplate');

  benchmarkUrl = function(url, opts, done) {
    if (opts.debuggingPort == null) {
      opts.debuggingPort = 9222;
    }
    return launchChrome(url, opts.debuggingPort, function(err, browser) {
      return runTest(url, opts.debuggingPort, function(err, testResult) {
        browser.kill();
        return done(err, testResult);
      });
    });
  };

  benchmarkHtml = function(htmlPath, opts, done) {
    var relativeHtmlPath, server;
    if (_.isFunction(opts) && (done == null)) {
      done = opts;
      opts = {};
    }
    if (opts.basePath == null) {
      opts.basePath = path.dirname(htmlPath);
    }
    relativeHtmlPath = path.relative(opts.basePath, htmlPath).split(path.sep).join('/');
    server = http.createServer(function(req, res) {
      return serveStatic(opts.basePath)(req, res, finalhandler(req, res));
    });
    return benchmarkWithServer(server, opts, relativeHtmlPath, done);
  };

  benchmarkJs = function(jsPath, opts, done) {
    if (_.isFunction(opts) && (done == null)) {
      done = opts;
      opts = {};
    }
    return fs.readFile(jsPath, function(err, src) {
      var server;
      if (err) {
        return done(err);
      }
      server = http.createServer(function(req, res) {
        res.writeHead(200, {
          "Content-Type": "text/html"
        });
        return res.end(jsTestTemplate(src));
      });
      return benchmarkWithServer(server, opts, '', done);
    });
  };

  benchmarkWithServer = function(server, opts, endpoint, done) {
    var url;
    if (opts.port == null) {
      opts.port = 8666;
    }
    if (opts.host == null) {
      opts.host = 'localhost';
    }
    url = "http://" + opts.host + ":" + opts.port + "/" + endpoint;
    return server.listen(opts.port, null, null, function(err, success) {
      if (err) {
        return done(err);
      }
      return benchmarkUrl(url, opts, function(err, testResult) {
        server.close();
        return done(err, testResult);
      });
    });
  };

  launchChrome = function(url, debuggingPort, done) {
    return launcher(function(err, launch) {
      if (err) {
        return done(err);
      }
      return launch(url, {
        browser: 'chrome',
        options: ["--remote-debugging-port=" + debuggingPort]
      }, done);
    });
  };

  module.exports = {
    url: benchmarkUrl,
    html: benchmarkHtml,
    js: benchmarkJs
  };

}).call(this);