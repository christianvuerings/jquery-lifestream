'use strict';

var angular = require('angular');

/**
 * Updated Feeds controller
 */
angular.module('calcentral.controllers').controller('UpdatedFeedsController', function(apiService, $scope) {
  $scope.hasUpdates = false;
  $scope.$on('calcentral.api.updatedFeeds.servicesWithUpdates', function() {
    $scope.hasUpdates = $scope.api.updatedFeeds.hasUpdates();
  });

  $scope.refreshFeeds = apiService.updatedFeeds.refreshFeeds;
});
