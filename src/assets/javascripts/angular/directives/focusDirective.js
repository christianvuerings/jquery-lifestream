(function(angular) {
  'use strict';

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
})(window.angular);
