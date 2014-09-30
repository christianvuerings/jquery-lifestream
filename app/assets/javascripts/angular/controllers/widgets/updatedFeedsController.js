(function(angular) {
  'use strict';

  /**
   * Updated Feeds controller
   */
  angular.module('calcentral.controllers').controller('UpdatedFeedsController', function($scope, apiService) {
    $scope.hasUpdates = false;
    $scope.$on('calcentral.api.updatedFeeds.servicesWithUpdates', function() {
      $scope.hasUpdates = $scope.api.updatedFeeds.hasUpdates();
    });

    $scope.refreshFeeds = apiService.updatedFeeds.refreshFeeds;
  });
})(window.angular);
