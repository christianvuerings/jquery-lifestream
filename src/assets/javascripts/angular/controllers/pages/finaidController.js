(function(angular) {
  'use strict';

  /**
   * Financial Aid controller
   */
  angular.module('calcentral.controllers').controller('FinaidController', function(apiService, finaidFactory, finaidService, $routeParams, $scope) {
    apiService.util.setTitle('Financial Aid');

    /**
     * Set whether you can a user can see the finaid year data
     */
    var setCanSeeFinaidYear = function(data) {
      $scope.canSeeFinaidData = finaidService.canSeeFinaidData(data, $routeParams.finaidYearId);
    };

    /**
     * Select the correct finaid year, if it doesn't exist, we need to send them to the 404 page
     */
    var selectFinaidYear = function(data) {
      $scope.finaidYear = finaidService.getSelectedFinaidYear(data, $routeParams.finaidYearId);

      // If no correct finaid year comes back, make sure to send them to the 404 page.
      if (!$scope.finaidYear) {
        apiService.util.redirect('404');
        return false;
      }
    };

    /**
     * Get the finaid summary information
     */
    var getFinaidSummary = function() {
      finaidFactory.getSummary().success(function(data) {
        angular.extend($scope, data);
        selectFinaidYear(data);
        setCanSeeFinaidYear(data);
      });
    };

    getFinaidSummary();
  });
})(window.angular);
