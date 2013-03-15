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

// Parses the command line into properties on argv. --watch <value> becomes argv.watch = <value>
var argv = require('optimist').argv;
var path = require('path');
// The chameleon server.
var server = require("./server");

// Only accept strings.
if (typeof argv.watch != 'string') {
  console.log("Usage:\n  node chameleon.js --watch <path to watch changes in> --bonjour <service_identifier>");
  return;
}

// Verify that the watch path exists.
if (!path.existsSync(argv.watch)) { // it's interesting that methods are assumed asynchronous by default.
  console.log("Unable to find path: "+argv.watch);
  return;
}

console.log("Starting chameleon...");
console.log("  Watching "+argv.watch);

server.start(argv.watch,argv.bonjour);
