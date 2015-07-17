'use strict';

var angular = require('angular');

/*
  Intended for use on content wrappers when nested elements are hidden/revealed using ngShow/ngHide/ngIf
  for the purpose of resetting the focus to the top of the page after loading an entire
  new view context.
*/
angular.module('calcentral.directives').directive('ccFocusResetDirective', function($timeout) {
  return {
    link: function(scope, elm, attrs) {
      scope.$watch(attrs.ccFocusResetDirective, function(value) {
        if (value === true) {
          elm[0].setAttribute('tabIndex', -1);
          $timeout(function() {
            elm[0].focus();
          }, 0);
          scope[attrs.ccFocusResetDirective] = false;
        }
      });
    }
  };
});
