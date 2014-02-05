var fs = require('fs');

fs.readdir(process.argv[2], function(err, files) {
  process.stdout.write(
    JSON.stringify(
      files.sort().map(function(v) { return v.replace(/\.js/, ''); })));
});

