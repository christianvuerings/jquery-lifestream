(function(calcentral) {
  'use strict';

  /**
   * Activity controller
   */
  calcentral.controller('ActivityController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/activities').success(function(data) {
      $scope.activities = data.activities;
    });

  }]);

})(window.calcentral);
