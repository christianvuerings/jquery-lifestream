(function(window, calcentral) {
  'use strict';

  /**
   * Admin controller
   */
  calcentral.controller('AdminController', ['$http', '$scope', function($http, $scope) {

    $scope.admin = {};

    var redirectToSettings = function() {
      window.location = '/settings';
    };

    /**
     * Act as someone else
     */
    $scope.admin.actAs = function() {
      if (!$scope.admin.act_as || !$scope.admin.act_as.uid) {
        return;
      }

      var user = {
        uid: $scope.admin.act_as.uid + ''
      };
      $http.post('/act_as', user).success(redirectToSettings);
    };

    /**
     * Stop acting as someone else
     */
    $scope.admin.stopActAs = function() {
      $http.post('/stop_act_as').success(redirectToSettings);
    };

  }]);

})(window, window.calcentral);
