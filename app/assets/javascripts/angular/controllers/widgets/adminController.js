(function(window, angular) {
  'use strict';

  /**
   * Admin controller
   */
  angular.module('calcentral.controllers').controller('AdminController', ['$http', '$scope', function($http, $scope) {

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

    var resetUserSearch = function() {
      $scope.admin.users = [];
      $scope.admin.errorStatus = '';
      $scope.admin.id = '';
    };

    $scope.admin.uidToSidLookup = function() {
      var searchUsersUri = 'api/search_users/' + $scope.admin.id;
      resetUserSearch();
      $http.get(searchUsersUri).success(function(data) {
        if (data.users.length > 0) {
          $scope.admin.users = data.users;
        } else {
          $scope.admin.errorStatus = 'That does not appear to be a valid UID or SID';
        }
      }).error(function(data) {
        if (data.error) {
          $scope.admin.errorStatus = data.error;
        } else {
          $scope.admin.errorStatus = 'User search failed.';
        }
      });
    };

  }]);

})(window, window.angular);
