(function(calcentral) {
  'use strict';

  /**
   * Settings controller
   */
  calcentral.controller('SettingsController', ['$scope', 'apiService', function($scope, apiService) {

    apiService.util.setTitle('Settings');

    var services = ['canvas', 'google'];

    var refreshServices = function(profile) {
      $scope.connected_services = services.filter(function(element) {
        return profile['has_' + element + '_access_token'];
      });
      $scope.non_connected_services = services.filter(function(element) {
        return !profile['has_' + element + '_access_token'];
      });
    };

    $scope.$on('calcentral.api.user.profile', function(event, profile) {
      if (profile) {
        refreshServices(profile);
      }
    });

    // We need to do another fetch for the following usecase
    // 1) We get the user status, which says you have a canvas token
    // 2) We fetch the user's canvas classes and get a 400 back
    // 3) Now we need to update the user status
    $scope.api.user._fetch();

  }]);

})(window.calcentral);
