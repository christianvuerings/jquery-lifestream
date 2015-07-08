(function(angular) {
  'use strict';

  /**
   * Directive for the finaid summary messages
   */
  angular.module('calcentral.directives').directive('ccFinaidSummaryMessageDirective', function() {
    return {
      templateUrl: 'directives/finaid_summary_message.html',
      scope: {
        item: '=',
        buttonText: '=',
        finaidYearId: '='
      }
    };
  });
})(window.angular);
