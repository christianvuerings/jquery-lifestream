(function(calcentral) {
  'use strict';

  /**
   * Dashboard controller
   */
  calcentral.controller('DashboardController', ['apiService', function(apiService) {

    apiService.util.setTitle('Dashboard');

  }]);

})(window.calcentral);
