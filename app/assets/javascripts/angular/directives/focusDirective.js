(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccFocusDirective', ['$timeout', function($timeout) {
    return {
      link: function(scope, elm, attrs, ctrl) {
        scope.$watch(attrs.ccFocusDirective, function(value) {
          if(value === true) {
            $timeout(function() {
              elm[0].focus();
            });
          }
        });
      }
    };
  }]);

})(window.angular);
