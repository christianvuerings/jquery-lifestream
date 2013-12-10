(function(angular) {
  'use strict';

  /**
   * Dashboard controller
   */
  angular.module('calcentral.controllers').controller('DashboardController', function(apiService) {

    apiService.util.setTitle('Dashboard');

  });

})(window.angular);
