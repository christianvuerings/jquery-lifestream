(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccFocusDirective', function($timeout) {
    return {
      link: function(scope, elm, attrs) {
        scope.$watch(attrs.ccFocusDirective, function(value) {
          if(value === true) {
            $timeout(function() {
              elm[0].focus();
            });
          }
        });
      }
    };
  });

})(window.angular);
