'use strict';

var angular = require('angular');

/**
 * Activity controller
 */
angular.module('calcentral.controllers').controller('FinaidActivityController', function(activityFactory, apiService, $scope) {
  var getFinaidActivity = function() {
    $scope.process = {
      isLoading: true
    };
    activityFactory.getFinaidActivity().then(function(data) {
      apiService.updatedFeeds.feedLoaded(data);
      angular.extend($scope, data);
      $scope.process.isLoading = false;
    });
  };

  $scope.mode = 'finaidActivity';

  getFinaidActivity();
});
