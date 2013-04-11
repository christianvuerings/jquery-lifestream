(function(window, calcentral) {
  'use strict';

  /**
   * Admin controller
   */
  calcentral.controller('AdminController', ['$http', '$scope', function($http, $scope) {

    $scope.admin = {};

    /**
     * Act as someone else
     */
    $scope.admin.actAs = function() {
      var user = {
        uid: $scope.admin.act_as.uid
      };
      $http.post('/act_as', user).success(function() {
        location.reload();
      });
    };

    /**
     * Stop acting as someone else
     */
    $scope.admin.stopActAs = function() {
      $http.post('/stop_act_as').success(function() {
        location.reload();
      });
    };

  }]);

})(window, window.calcentral);
