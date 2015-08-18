'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccAccessibleFocusDirective', function() {
  return {
    restrict: 'A', // Restrict it to attributes.
    link: function(scope, elm, attrs) {
      var enableFocusDirective = scope.$eval(attrs.ccAccessibleFocusDirective);

      // Disable the directive when you pass a `false` value to it
      if (enableFocusDirective === false) {
        return;
      }

      // Set the tabindex attribute so we can tab into it.
      attrs.$set('tabindex', 0);
      elm.bind('keydown', function(event) {
        // Check whether you've hit the ENTER key
        // and whether the element itself is actually focussed
        if (event.which === 13 && document.activeElement === elm[0]) {
          scope.$apply(function() {
            // Execute the click function
            scope.$eval(attrs.ngClick);
          });

          event.preventDefault();
        }
      });
    }
  };
});
