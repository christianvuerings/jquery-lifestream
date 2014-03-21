(function(angular) {
  'use strict';

  /**
   * Alerts controller
   */
  angular.module('calcentral.controllers').controller('AlertsController', function(badgesFactory, $scope) {

    badgesFactory.getBadges().success(function(data) {
      $scope.alert = data.alert;
    });

  });

})(window.angular);
