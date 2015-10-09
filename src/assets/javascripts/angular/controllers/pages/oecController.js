'use strict';

var angular = require('angular');

/**
 * OEC Control Panel app controller
 */
angular.module('calcentral.controllers').controller('OecController', function(apiService, oecFactory, $scope, $timeout) {
  $scope.initialize = function() {
    oecFactory.getOecTasks().success(function(data) {
      apiService.util.setTitle('OEC Control Panel');
      angular.extend($scope, data);
      $scope.displayError = null;
      $scope.oecTaskStatus = null;
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

  var handleTaskStatus = function(data) {
    angular.extend($scope.oecTaskStatus, data.oecTaskStatus);
    if ($scope.oecTaskStatus.status === 'In progress') {
      pollTaskStatus();
    } else {
      $timeout.cancel(timeoutPromise);
      $scope.oecTaskStatus.log.push('Task completed with status \'' + $scope.oecTaskStatus.status + '.\'');
    }
  };

  var timeoutPromise;
  var pollTaskStatus = function() {
    timeoutPromise = $timeout(function() {
      return oecFactory.oecTaskStatus($scope.oecTaskStatus.id)
        .success(handleTaskStatus).error(function() {
          $scope.displayError = 'failure';
        });
    }, 2000);
  };

  var sanitizeTaskOptions = function() {
    if (!$scope.taskParameters.selectedTask.acceptsDepartmentOptions) {
      $scope.taskParameters.options.departmentCode = null;
    }
  };

  $scope.runOecTask = function() {
    sanitizeTaskOptions();
    return oecFactory.runOecTask($scope.taskParameters.selectedTask.name, $scope.taskParameters.options).success(function(data) {
      angular.extend($scope, data);
      pollTaskStatus();
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
