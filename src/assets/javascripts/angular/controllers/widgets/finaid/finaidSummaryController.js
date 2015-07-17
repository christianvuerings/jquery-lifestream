'use strict';

var angular = require('angular');

/**
 * Finaid Summary controller
 */
angular.module('calcentral.controllers').controller('FinaidSummaryController', function(finaidFactory, finaidService, $scope) {
  /**
   * Get the financial aid summary information
   */
  var getFinaidSummary = function() {
    finaidFactory.getSummary().success(function(data) {
      angular.extend($scope, data);
      $scope.finaidYear = finaidService.getSelectedFinaidYear(data);
    });
  };

  getFinaidSummary();
});
