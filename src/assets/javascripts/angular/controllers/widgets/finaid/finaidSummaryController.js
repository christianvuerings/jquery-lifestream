(function(angular) {
  'use strict';

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
})(window.angular);
