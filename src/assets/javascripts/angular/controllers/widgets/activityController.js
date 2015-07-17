'use strict';

var angular = require('angular');

/**
 * Activity controller
 */
angular.module('calcentral.controllers').controller('ActivityController', function(activityFactory, apiService, dateService, $scope) {
  var getMyActivity = function(options) {
    $scope.process = {
      isLoading: true
    };
    activityFactory.getActivity(options).then(function(data) {
      apiService.updatedFeeds.feedLoaded(data);
      angular.extend($scope, data);
      $scope.process.isLoading = false;
    });
  };

  $scope.mode = 'activity';

  $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
    if (services && services['MyActivities::Merged']) {
      getMyActivity({
        refreshCache: true
      });
    }
  });
  getMyActivity();
});
