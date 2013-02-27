(function(calcentral) {
  'use strict';

  /**
   * Splash controller
   */
  calcentral.controller('SplashController', ['$http', '$scope', 'apiService', function($http, $scope, apiService) {

    apiService.util.setTitle('Home');

    $http.get('/api/blog/release_notes/latest').success(function(data) {
      $scope.latest_release_note = data.entries[0];
    });

  }]);

})(window.calcentral);
