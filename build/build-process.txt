# Build Process

## Required Tools
- GNU Make
- Node.js
- UglifyJS

## Tools Installation Tips
- Make
- Node
- UglifyJS

## Building

### Directory Structure
src

src/services

dist 
The distribution directory. This will be created by the build process.
The built jquery.lifestream.js and jquery.lifestream.min.js will go here.

build
Contains files needed by the build process.


### Use of Make

#### Available targets

jls
Build dist/jquery.lifestream.js

jls-min 
Build dist/jquery.lifestream.min.js

uglifyjs 
Build download/js/uglify-cs.js, a custom version of UglifyJS patched
to work in the browser; needed by CDB

uglifyjs-min 
Build download/js/uglify-cs.min.js

service-list
Build download/services.txt, needed by CDB