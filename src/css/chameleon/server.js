var http = require("http");
var url = require("url");
var path = require('path');
var fs = require('fs');

var change_set = {};
var active_watchers = [];

function start(watch_path) {
  function onServeFile(request, response, pathname) {
    var localFile = path.join(watch_path, pathname);

    if (!path.existsSync(localFile)) {
      response.writeHead(404);
      response.end();
      return;
    }

    fs.readFile(localFile, function(error, content) {
  		if (error) {
  			response.writeHead(500);
  			response.end();

  		} else {
  			response.writeHead(200, { 'Content-Type': 'text/css' });
  			response.end(content, 'utf-8');
  		}
  	});
  }

  function onWatch(request, response) {
    var consume = function() {
    	response.writeHead(200, { 'Content-Type': 'text/plain' });
    	var changed = [];
    	for (var key in change_set) {
    	  changed.push(key);
    	}
  	  response.write(changed.join("\n"), 'utf-8');
    	response.end("", 'utf-8');
    };
    var any_keys = false;
    for (var key in change_set) {
      any_keys = true;
    }
    if (!any_keys) {
      active_watchers.push(consume);
    } else {
      consume();
      change_set = {};
    }
  }

  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname;

    if (pathname == "/watch") {
      onWatch(request, response);
    } else {
      onServeFile(request, response, pathname);
    }
  }

  // Watch all of the files for changes.
  fs.readdir(watch_path, function (err, files) {
    if (err) throw err;
    for (var ix = 0; ix < files.length; ++ix) {
      var filename = path.join(watch_path, files[ix]);

      var watch = function(this_path, short_name) {
        fs.watchFile(this_path, function (curr, prev) {
          if (curr.mtime != prev.mtime) {
            change_set[short_name] = true;

            // Notify all of the active watchers that the history has changed.
            if (active_watchers.length > 0) {
              for (var key in active_watchers) {
                active_watchers[key]();
              }
              active_watchers = [];
              change_set = {};
            }
          }
        });
      };
      watch(filename, files[ix]);
    }
  });
  
  var port = 8888;
  http.createServer(onRequest).listen(port);
  console.log("  Server: http://127.0.0.1:"+port+"/");
}

exports.start = start;