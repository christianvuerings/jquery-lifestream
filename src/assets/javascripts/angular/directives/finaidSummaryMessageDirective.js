'use strict';

var angular = require('angular');

/**
 * Directive for the finaid summary messages
 */
angular.module('calcentral.directives').directive('ccFinaidSummaryMessageDirective', function() {
  return {
    templateUrl: 'directives/finaid_summary_message.html',
    scope: {
      item: '=',
      buttonText: '=',
      finaidUrl: '='
    }
  };
});
