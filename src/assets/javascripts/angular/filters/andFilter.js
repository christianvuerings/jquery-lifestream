'use strict';

var angular = require('angular');

/**
 * And filter
 * Seperate items with commas and the last one with 'and'
 * ['Item 1'] => Item 1'
 * ['Item 1', 'Item 2'] => Item 1 and Item 2
 * ['Item 1', 'Item 2', 'Item 3'] => Item 1, Item 2 and Item 3
 */
angular.module('calcentral.filters').filter('andFilter', function() {
  var delimiter = ', ';
  var delimiterLength = delimiter.length;
  return function(items) {
    var joinedString = items.join(delimiter);

    var lastIndex = joinedString.lastIndexOf(delimiter);
    if (lastIndex !== -1) {
      joinedString = joinedString.substr(0, lastIndex) + ' and ' + joinedString.substr(lastIndex + delimiterLength);
    }
    return joinedString;
  };
});
