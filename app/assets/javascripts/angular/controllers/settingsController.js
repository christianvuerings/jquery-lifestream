(function(calcentral) {
  'use strict';

  /**
   * Settings controller
   */
  calcentral.controller('SettingsController', ['$http', '$scope', 'apiService', function($http, $scope, apiService) {

    apiService.util.setTitle('Settings');

    $scope.refreshServices = function() {

      $scope.connected_services = [];
      $scope.non_connected_services = [];

      $http.get('/api/my/status').success(function(data) {
        // Put connected/non-connected services into buckets we can iterate through and count.

        if (data.has_canvas_access_token) {
          $scope.connected_services.push('canvas');
        } else {
          $scope.non_connected_services.push('canvas');
        }

        if (data.has_google_access_token) {
          $scope.connected_services.push('google');
        } else {
          $scope.non_connected_services.push('google');
        }

      });
    };
    $scope.refreshServices();
  }]);

})(window.calcentral);
