'use strict';

var angular = require('angular');

/**
 * iOS devices don't support event bubbling all the way to the top.
 * We need this capability since we need to close popovers when we tap/touch/click outside of them.
 */
angular.module('calcentral.directives').directive('ccIosfixDirective', [function() {
  return {
    link: function(scope, elm) {
      // Check whether we have the user is using an iOS device
      // Usually we would want to to feature detection (e.g. for touch events) but we actually
      // only want to set this on iOS devices. e.g. on a chromebook it would show a hand cursor
      // everywhere
      if (!!navigator.userAgent.match(/(iPad|iPhone|iPod)/g)) {
        // Instead of setting a class here, we'll actually use some in-line CSS
        // The reason for doing this is to make sure that this directive is easily pluggable.
        elm.css('cursor', 'pointer');
      }
    }
  };
}]);
