'use strict';

var angular = require('angular');

/**
 * Used to resize the iframe for bCourses embedded applications based on the DIV wrapper
 */
angular.module('calcentral.directives').directive('bcIframeResize', function(apiService) {
  return {
    restrict: 'A',
    link: function(scope, elm) {
      apiService.util.iframeUpdateHeight(elm);
    }
  };
});
