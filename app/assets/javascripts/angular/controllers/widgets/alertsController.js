(function(angular) {
  'use strict';

  /**
   * Alerts controller
   */
  angular.module('calcentral.controllers').controller('AlertsController', function($rootScope, $scope) {

    $rootScope.$on('calcentral.controller.badges.alert', function(event, alert) {
      $scope.alert = alert;
    });

  });

})(window.angular);
