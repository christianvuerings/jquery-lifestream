/* jshint node:true */
var fs = require('fs'),
  path = require('path'),
  baseDir = process.argv[2],
  files = [],
  mimeTypes = {
    'gif': 'image/gif',
    'jpe': 'image/jpeg',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png'
  },
  styles = '';

// get the mime type based on extension
// easier than installing modules, but more accident-prone
var getMimeType = function(filepath) {
  var extension = path.extname(filepath).replace('.', '');

  return mimeTypes[extension];
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
  var allowedExtensions = Object.keys(mimeTypes),
    fileExtension = path.extname(filename).replace('.', '');
  // make sure only allowed files are parse
  if ( allowedExtensions.indexOf(fileExtension) >= 0 ) {
    styles += base64Encode( baseDir + '/' + filename ) + "\n";
  }
});

process.stdout.write(styles);
