'use strict';

var angular = require('angular');

/**
 * OEC Control Panel app controller
 */
angular.module('calcentral.controllers').controller('OecController', function(apiService, oecFactory, $scope) {
  $scope.initialize = function() {
    oecFactory.getOecTasks().success(function(data) {
      apiService.util.setTitle('OEC Control Panel');
      angular.extend($scope, data);
      $scope.displayError = null;
      $scope.taskInProgress = false;
      $scope.taskParameters = {
        selectedTask: {
          name: null
        },
        options: {
          term: data.currentTerm
        }
      };
    }).error(function(data, status) {
      $scope.isLoading = false;
      if (status === 403) {
        $scope.displayError = 'unauthorized';
      } else {
        $scope.displayError = 'failure';
      }
    });
  };

  $scope.runOecTask = function() {
    return oecFactory.runOecTask($scope.taskParameters.selectedTask.name, $scope.taskParameters.options).success(function(data) {
      if (data.success) {
        $scope.taskInProgress = true;
        $scope.oecDriveUrl = data.oecDriveUrl;
      }
    }).error(function() {
      $scope.displayError = 'failure';
    });
  };

  // Wait until user profile is fully loaded before starting.
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.initialize();
    }
  });
});
