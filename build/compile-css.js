/* jshint node:true */
var fs = require('fs'),
  path = require('path'),
  baseDir = process.argv[2],
  files = [],
  styles = '';

// get the mime type base on extension
// easier than installing modules, but more accident-prone
var getMimeType = function(filepath) {
  var types = {
    'gif': 'image/gif',
    'jpe': 'image/jpeg',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png'
  },
  extension = path.extname(filepath).replace('.', '');

  return types[extension];
};

// gets an image and gives you the full css class
var base64Encode = function(filepath) {
  return '.lifestream-' + path.basename(filepath, path.extname(filepath)) +
    '{background-image:url(data:' + getMimeType(filepath) +
    ';base64,' + fs.readFileSync(filepath).toString('base64') +
    ')}';
};

files = fs.readdirSync(baseDir);
files.sort().forEach(function(filename){
  styles += base64Encode( baseDir + '/' + filename ) + "\n";
});

process.stdout.write(styles);
