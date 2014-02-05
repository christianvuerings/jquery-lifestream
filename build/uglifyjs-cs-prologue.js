(function() {

var 
  modules = {
    './parse-js': {},
    './process': {},
    './squeeze-more': {}
  },
  require = function(module) {
    return modules[module];
  }
;

// For older browsers that does not support
// the ECMA 5 Array.prototype.reduce() method.
// This implemention come from
// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/array/reduce
if (!Array.prototype.reduce) {
  Array.prototype.reduce = function reduce(accumlator) {
    var i, l = this.length, curr;
        
    if (typeof accumlator !== "function") // ES5 : "If IsCallable(callbackfn) is false, throw a TypeError exception."
      throw new TypeError("First argument is not callable");

    if ((l == 0 || l === null) && (arguments.length <= 1)) // == on purpose to test 0 and false.
      throw new TypeError("Array length is 0 and no second argument");
        
    if (arguments.length <= 1) {
      for (i=0; i = l;) // empty array
        throw new TypeError("Empty array and no second argument");
      curr = this[i++]; // Increase i to start searching the secondly defined element in the array
    }
    else{
      curr = arguments[1];
    }
        
    for (i = i || 0; i < l; i++) {
      if (i in this)
        curr = accumlator.call(undefined, curr, this[i], i, this);
    }
        
    return curr;
  };
}

// For older browsers that does not support
// the ECMA 5 Array.prototype.forEach() method.
// This implemention come from
// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/array/foreach
// Production steps of ECMA-262, Edition 5, 15.4.4.18
if (!Array.prototype.forEach) {
  Array.prototype.forEach = function( callbackfn, thisArg ) {
    var T,
      O = Object(this),
      len = O.length >>> 0,
      k = 0;

    if ( !callbackfn || !callbackfn.call ) {
      throw new TypeError();
    }

    if ( thisArg ) {
      T = thisArg;
    }

    while( k < len ) {

      var Pk = String( k ),
        kPresent = O.hasOwnProperty( Pk ),
        kValue;

      if ( kPresent ) {
        kValue = O[ Pk ];

        callbackfn.call( T, kValue, k, O );
      }

      k++;
    }
  };
}
