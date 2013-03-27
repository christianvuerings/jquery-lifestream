/**
 * Truncate Filter Usage
 * http://jsfiddle.net/tUyyx/
 *
 * var myText = "This is an example.";
 *
 * {{myText|Truncate}}
 * {{myText|Truncate:5}}
 * {{myText|Truncate:25:" [More]"}}
 * Output
 * "This is..."
 * "Th..."
 * "This is an e [More]"
 */

(function(angular) {
  'use strict';

  angular.module('calcentral.filters', []).filter('truncate', function () {
    return function(text, length, end) {
      if (end === undefined) {
        end = '...';
      }
      if (text.length <= length || text.length - end.length <= length) {
        return text;
      } else {
        text = text + '';
        return text.substring(0, length-end.length) + end;
      }
    };
  });

})(window.angular);
