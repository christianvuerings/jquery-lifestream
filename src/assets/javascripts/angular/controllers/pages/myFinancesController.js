(function(angular) {
  'use strict';

  /**
   * My Finances controller
   */
  angular.module('calcentral.controllers').controller('MyFinancesController', function(apiService) {
    apiService.util.setTitle('My Finances');
  });
})(window.angular);
