'use strict';

var angular = require('angular');

/**
 * Directive for the finaid permissions
 */
angular.module('calcentral.directives').directive('ccFinaidSummaryItemDirective', function() {
  return {
    templateUrl: 'directives/finaid_summary_item.html',
    scope: {
      item: '='
    }
  };
});
