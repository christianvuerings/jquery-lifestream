(function(calcentral) {
  'use strict';

  /**
   * Dashboard controller
   */
  calcentral.controller('DashboardController', ['titleService', function(titleService) {

    titleService.setTitle('Dashboard');

  }]);

})(window.calcentral);
