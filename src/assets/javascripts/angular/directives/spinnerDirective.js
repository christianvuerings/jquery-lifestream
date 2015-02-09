(function(angular) {
  'use strict';

  /**
   * This attribute will replace the element by a spinner until data is returned in an HTTP respsonse.
   */
  angular.module('calcentral.directives').directive('ccSpinnerDirective', function() {
    return {
      restrict: 'A',
      link: function(scope, elment, attrs) {
        scope.isLoading = true;

        // Make sure we don't interupt the screenreader
        attrs.$set('aria-live', 'polite');

        /**
         * Check whether isLoading has changed
         */
        var watch = function(value) {
          attrs.$set('aria-busy', value);
          elment.toggleClass('cc-spinner', value);
        };

        // This allows us to watch for a different variable than isLoading
        // We need this when we're using ngInclude
        if (attrs.ccSpinnerDirective) {
          scope.$watch(attrs.ccSpinnerDirective, watch);
        } else {
          scope.$watch('isLoading', watch);
        }
      }
    };
  });
})(window.angular);
