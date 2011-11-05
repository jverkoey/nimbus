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

var changeSet = {};
var activeWatcher = null;

var port = 8888;
var watchInterval = 500; // 500 ms makes it effectively instant.

/**
 * Starts the Chameleon HTTP server and file watcher on the given path.
 */
function start(watchPath) {
	var extPath = watchPath.replace(/\w+\/?$/, 'ext');

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

    fs.readFile(localFile, 'utf8', function(error, content) {
  		if (error) {
  			response.writeHead(500);
  			response.end();
      } else {
  			response.writeHead(200, { 'Content-Type': 'text/css' });
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
    var sendResponse = function() {
    	response.writeHead(200, { 'Content-Type': 'text/plain' });
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
    fs.watchFile(path, { persistent: true, interval: watchInterval }, function (curr, prev) {
      if (curr.mtime.getTime() != prev.mtime.getTime()) {
        changeSet[shortName] = true;

        if (null != activeWatcher) {
          activeWatcher();
          activeWatcher = null;
        }
      }
    });
  }

  /**
	 * Start watching the CSS extension files and compiles the CSS every time that
	 * that the extension file is modified
	 */
  function watchExtFileAtPath(filePath, shortName) {
    fs.watchFile(filePath, { persistent: true, interval: watchInterval }, function (curr, prev) {
      if (curr.mtime.getTime() != prev.mtime.getTime()) {
        writeExtFile(filePath, shortName);
      }
    });
  }

  /**
	 * Verified the CSS extension that should be used to compile the CSS
	 * Currently, only .still (Stylus) files are supported
	 */
  var writeExtFile = function(filePath, shortName) {
    if (path.extname(filePath).toLowerCase() == '.styl') {
      writeStylusFile(filePath, shortName);
    }
    //Add here support for Sass and Less
  }

  /**
	 * Compiles the CSS file. This function read the input file and compiles the
	 * css to the target destination. The output directory maintains the directory
	 * hierarchy from the extensions directory.
	 * The file name will be composed of the 'originalfilename_<format>.css'. 
	 * For example, a file located in ext/test/root.styl will be written to
	 * css/test/root_stylus.css
	 *
	 * A watch will be put on target css file, if it is the first time that it is
	 * being written
	 */
  var writeStylusFile = function(filePath, shortName){
    var shortOutputName = path.dirname(shortName) + '/' + path.basename(filePath, '.styl') + '_stylus.css';
    var outputFile = watchPath + shortOutputName;

    var content = fs.readFileSync(filePath, 'utf8');
    var result = '';
    var stylus = require('stylus');
    stylus.render(content, { filename: path.basename(filePath) }, function(err, css){
      if (err) {
        console.log('An error happened ' + err);
      } else {
			  mkdir_p(path.dirname(outputFile), 0755, function(err) {
				  if (err) throw err;
          if (!path.existsSync(outputFile)) {
            fs.writeFileSync(outputFile, css);
            watchFileAtPath(outputFile, shortOutputName);
          } else {
            fs.writeFileSync(outputFile, css);
          }
        }, 0);
      }
    });
  }

	/**
	 * This function was taken from http://unfoldingtheweb.com/2010/12/15/recursive-directory-nodejs
	 * It creates directories recursively
	 */
  function mkdir_p(dirPath, mode, callback, position) {
    mode = mode || 0777;
    position = position || 0;
    parts = require('path').normalize(dirPath).split('/');

    if (position >= parts.length) {
        if (callback) {
            return callback();
        } else {
            return true;
        }
    }

    var directory = parts.slice(0, position + 1).join('/');
    fs.stat(directory, function(err) {
        if (err === null) {
            mkdir_p(dirPath, mode, callback, position + 1);
        } else {
            fs.mkdir(directory, mode, function (err) {
                if (err) {
                    if (callback) {
                        return callback(err);
                    } else {
                        throw err;
                    }
                } else {
                    mkdir_p(dirPath, mode, callback, position + 1);
                }
            })
        }
     });
   }

  // W00t to chjj for saving me time on this one.
  // http://stackoverflow.com/questions/5827612/node-js-fs-readdir-recursive-directory-search
  var walk = function(dir, done) {
    var results = [];
    fs.readdir(dir, function(err, list) {
      if (err) return done(err);
      (function next(i) {
        var file = list[i];
        if (!file) return done(null, results);
        file = path.join(dir, file);
        fs.stat(file, function(err, stat) {
          if (stat && stat.isDirectory()) {
            walk(file, function(err, res) {
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
  // When an extension file is found, it compiles the CSS
  var watchFiles = function(basePath, files) {
    for (var i = 0; i < files.length; ++i) {
      var fullPath = files[i];
      var shortName = fullPath.substr(basePath.length);

      if (path.extname(shortName).toLowerCase() == '.styl') {
        writeExtFile(fullPath, shortName);
        watchExtFileAtPath(fullPath, shortName);
      }

      // Only watch css files.
      if (path.extname(shortName).toLowerCase() == '.css') {
        watchFileAtPath(fullPath, shortName);
      }
    }
  }

  // We are first traversing the css files directory
	// Then we traverse the extensions directory. 
  walk(watchPath, function(err, cssFiles) {
    if (err) throw err;
    watchFiles(watchPath, cssFiles);
    //Walk the extensions directory
    if (path.existsSync(extPath)) {
      walk(extPath, function(err, extFiles) {
        if (err) throw err;
        watchFiles(extPath, extFiles);
      });
    }
  });

  http.createServer(onRequest).listen(port);
  console.log("  Server: http://localhost:" + port + "/");
}

// This allows us to call server.start from the chameleon.js file.
exports.start = start;
