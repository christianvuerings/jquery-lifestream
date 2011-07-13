(function() {

var 
  modules = {
    './parse-js': {},
    './process': {},
    './squeeze-more': {} // Watchout for the strange cyclic dep
  },
  require = function(module) {
    return modules[module];
  }
;
