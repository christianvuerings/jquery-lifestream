(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccSelectOnClickDirective', function() {
    return {
      restrict: 'A',
      link: function(scope, elm) {
        elm.on('click', function() {
          this.select();
        });
      }
    };
  });
})(window.angular);
