'use strict';

var angular = require('angular');

/**
 * Make sure that links with a disabled attribute are in fact disabled
 * - Adds the correct ARIA roles
 *
 * e.g.
 * <a href="https://twitter.com/redconfetti" cc-disabled="foo === 'bar'">redconfetti</a>
 */
angular.module('calcentral.directives').directive('a', function($parse) {
  return {
    restrict: 'E',
    // We need a very high priority, otherwise ngClick events still fire
    priority: 1000000,
    // Also make sure ngClick events aren't fired
    require: '?ngClick',
    link: function(scope, element, attrs) {
      if (attrs.ccDisabled) {
        // Parse the disabled property
        var disabled = $parse(attrs.ccDisabled);

        // Disable the click event
        element.bind('click', function(e) {
          if (disabled(scope)) {
            e.preventDefault();
            e.stopImmediatePropagation();
            return false;
          }

          return true;
        });

        // Also watch for changes in the disabled property
        scope.$watch(disabled, function(val) {
          if (val) {
            attrs.$set('aria-disabled', 'true');
            attrs.$set('disabled', 'true');
          } else {
            attrs.$set('aria-disabled', 'false');
            element.removeAttr('disabled');
          }
        });
      }
    }
  };
});
