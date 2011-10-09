var argv = require('optimist').argv;
var server = require("./server");
var path = require('path');

if (typeof argv.watch != 'string') {
  console.log("Usage:\n  node chameleon.js --watch <path to watch changes in>");
  return;
}

if (!path.existsSync(argv.watch)) {
  console.log("Unable to find path: "+argv.watch);
  return;
}

console.log("Starting chameleon...");
console.log("  Watching "+argv.watch);

server.start(argv.watch);
