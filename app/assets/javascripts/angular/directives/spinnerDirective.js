(function(angular) {
  'use strict';

  /**
   * This attribute will replace the element by a spinner until data is returned in an HTTP respsonse.
   */
  angular.module('calcentral.directives').directive('ccSpinnerDirective', function() {
    return {
      restrict: 'A',
      link: function(scope, elm) {
        scope.isLoading = true;

        /**
         * Check whether isLoading has changed
         */
        var watch = function(value) {
          elm.toggleClass('cc-spinner', value);
        };

        scope.$watch('isLoading', watch);
      }
    };
  });

})(window.angular);
