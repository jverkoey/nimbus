//
// Copyright 2011 Jeff Verkoeyen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

var http = require("http");
var url = require("url");
var path = require('path');
var fs = require('fs');
var mdns = null;

var changeSet = {};
var activeWatcher = null;

var port = 8888;
var watchInterval = 500; // 500 ms makes it effectively instant.

/**
 * Starts the Chameleon HTTP server and file watcher on the given path.
 */
function start(watchPath,bonjour) {

    if (bonjour) {
	mdns = require('mdns');
    }
    /**
     * Load a file from disk and pipe it down.
     */
    function onServeFile(request, response, pathname) {
        var localFile = path.join(watchPath, pathname);

        if (!path.existsSync(localFile)) {
            response.writeHead(404);
            response.end();
            return;
        }

        fs.readFile(localFile, function (error, content) {
            if (error) {
                response.writeHead(500);
                response.end();
            } else if (path.extname(localFile).toLowerCase() == ".strings") {
                response.writeHead(200, { 'Content-Type':'text/plain' });
                response.end(content, 'utf-8');
            } else if (path.extname(localFile).toLowerCase() == ".json") {
                response.writeHead(200, { 'Content-Type':'application/json' });
                response.end(content, 'utf-8');
            } else {
                response.writeHead(200, { 'Content-Type':'text/css' });
                response.end(content, 'utf-8');
            }
        });
    }

    /**
     * A new HTTP request has been started that wants to know what files have changed.
     * If files have changed since the last time a watch request was made then the changed
     * files will be returned immediately.
     * Otherwise the consume method will be stowed away until a file does change.
     */
    function onWatch(request, response) {
	console.log("Client connected from", request.connection.remoteAddress);
        var sendResponse = function () {
            response.writeHead(200, { 'Content-Type':'text/plain' });
            var changed = [];
            for (var key in changeSet) {
                changed.push(key);
            }
            response.write(changed.join("\n"), 'utf-8');
            response.end("", 'utf-8');
            changeSet = {};
        };

        var anyKeys = false;
        for (var key in changeSet) {
            // Ensure that we're only checking keys for the changeSet and nothing that was inherited.
            if (changeSet.hasOwnProperty(key)) {
                anyKeys = true;
                break;
            }
        }

        if (!anyKeys) {
            activeWatcher = sendResponse;
        } else {
            // Consume all of the changes immediately.
            sendResponse();
        }
    }

    /**
     * The general purpose entry-point for HTTP requests.
     */
    function onRequest(request, response) {
        var pathname = url.parse(request.url).pathname;

        if (pathname == "/watch") {
            onWatch(request, response);

        } else {
            onServeFile(request, response, pathname);
        }
    }

    /**
     * Starts watching changes on the given file. shortName is effectively just the relative
     * path to watchDir.
     */
    function watchFileAtPath(path, shortName) {
        fs.watchFile(path, { persistent:true, interval:watchInterval }, function (curr, prev) {
            if (curr.mtime.getTime() != prev.mtime.getTime()) {
                changeSet[shortName] = true;

                if (null != activeWatcher) {
                    activeWatcher();
                    activeWatcher = null;
                }
            }
        });
    }

    // W00t to chjj for saving me time on this one.
    // http://stackoverflow.com/questions/5827612/node-js-fs-readdir-recursive-directory-search
    var walk = function (dir, done) {
        var results = [];
        fs.readdir(dir, function (err, list) {
            if (err) return done(err);
            (function next(i) {
                var file = list[i];
                if (!file) return done(null, results);
                file = path.join(dir, file);
                fs.stat(file, function (err, stat) {
                    if (stat && stat.isDirectory()) {
                        walk(file, function (err, res) {
                            results = results.concat(res);
                            next(++i);
                        });
                    } else {
                        results.push(file);
                        next(++i);
                    }
                });
            })(0);
        });
    };

    // Watch all of the files in the watch path recursively.
    walk(watchPath, function (err, results) {
        if (err) throw err;
        for (var i = 0; i < results.length; ++i) {
            var fullPath = results[i];
            var shortName = fullPath.substr(watchPath.length);

            // Only watch css files.
            if (path.extname(shortName).toLowerCase() == '.css') {
                console.log("Watching", fullPath);
                watchFileAtPath(fullPath, shortName);
            }
            // And strings files
            else if (path.extname(shortName).toLowerCase() == '.strings') {
                console.log("Watching", fullPath);
                watchFileAtPath(fullPath, shortName);
            }
            // And json files
            else if (path.extname(shortName).toLowerCase() == ".json") {
                console.log("Watching", fullPath);
                watchFileAtPath(fullPath, shortName);
            }
        }
    });

    http.createServer(onRequest).listen(port);
    console.log("  Server: http://localhost:" + port + "/");

    if (bonjour) {
	var ad = mdns.createAdvertisement(mdns.tcp(bonjour), port);
	ad.start();
    }
}

// This allows us to call server.start from the chameleon.js file.
exports.start = start;
