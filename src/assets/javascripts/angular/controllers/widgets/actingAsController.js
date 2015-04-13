(function(angular) {
  'use strict';

  /**
   * 'Acting as' controller
   */
  angular.module('calcentral.controllers').controller('ActingAsController', function(adminFactory, apiService, $scope) {
    $scope.admin = {};

    /**
     * Stop acting as someone else
     */
    $scope.admin.stopActAs = function() {
      adminFactory.stopActAs().success(apiService.util.redirectToSettings).error(apiService.util.redirectToSettings);
    };
  });
})(window.angular);
