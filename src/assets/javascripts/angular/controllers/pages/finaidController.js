'use strict';

var angular = require('angular');

/**
 * Financial Aid controller
 */
angular.module('calcentral.controllers').controller('FinaidController', function(apiService, finaidFactory, finaidService, $routeParams, $scope) {
  apiService.util.setTitle('Financial Aid');

  $scope.isMainFinaid = true;
  $scope.finaid = {
    isLoading: true
  };

  /**
   * Set whether you can a user can see the finaid year data
   */
  var setCanSeeFinaidYear = function(data, finaidYear) {
    $scope.canSeeFinaidData = finaidService.canSeeFinaidData(data, finaidYear);
  };

  /**
   * Set the current finaid year
   */
  var setFinaidYear = function(data, finaidYearId) {
    $scope.finaidYear = finaidService.findFinaidYear(data, finaidYearId);
  };

  /**
   * See whether the finaid year, semester option combination exist, otherwise, send them to the 404 page
   */
  var combinationExists = function(data, finaidYearId, semesterOptionId) {
    var finaidYear = finaidService.combinationExists(data, finaidYearId, semesterOptionId);

    // If no correct finaid year comes back, make sure to send them to the 404 page.
    if (!finaidYear) {
      apiService.util.redirect('404');
      return false;
    }
  };

  /**
   * Get the finaid summary information
   */
  var getFinaidSummary = function() {
    return finaidFactory.getSummary().success(function(data) {
      combinationExists(data.feed, $routeParams.finaidYearId, $routeParams.semesterOptionId);
      setFinaidYear(data.feed, $routeParams.finaidYearId);
      setCanSeeFinaidYear(data.feed, $scope.finaidYear);
      $scope.finaid.isLoading = false;
    });
  };

  getFinaidSummary();
});
