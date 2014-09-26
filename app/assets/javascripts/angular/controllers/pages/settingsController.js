(function(angular) {
  'use strict';

  /**
   * Settings controller
   */
  angular.module('calcentral.controllers').controller('SettingsController', function($scope, apiService) {

    apiService.util.setTitle('Settings');

    var services = ['Google'];

    var refreshIsCalendarOptedIn = function(profile) {
      $scope.settings = {
        isCalendarOptedIn: profile.isCalendarOptedIn
      };
    };

    var refreshServices = function(profile) {
      $scope.connectedServices = services.filter(function(element) {
        return profile['has' + element + 'AccessToken'];
      });
      $scope.disConnectedServices = services.filter(function(element) {
        return !profile['has' + element + 'AccessToken'];
      });
    };

    $scope.$on('calcentral.api.user.profile', function(event, profile) {
      if (profile) {
        refreshIsCalendarOptedIn(profile);
        refreshServices(profile);
      }
    });

    // We need to do another fetch for the following usecase
    // 1) We get the user status, which says you have a canvas token
    // 2) We fetch the user's canvas classes and get a 400 back
    // 3) Now we need to update the user status
    $scope.api.user.fetch({
      refreshCache: true
    });

  });

})(window.angular);
