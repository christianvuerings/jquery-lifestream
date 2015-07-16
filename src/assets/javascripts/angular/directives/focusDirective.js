'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccFocusDirective', function() {
  return {
    link: function(scope, elm, attrs) {
      scope.$watch(attrs.ccFocusDirective, function(value) {
        if (value === true) {
          scope.$evalAsync(function() {
            elm[0].focus();
          });
        }
      });
    }
  };
});
