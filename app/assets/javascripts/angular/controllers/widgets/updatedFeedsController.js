(function(angular) {
  'use strict';

  /**
   * Updated Feeds controller
   */
  angular.module('calcentral.controllers').controller('UpdatedFeedsController', function($scope, apiService) {

    $scope.has_updates = false;
    $scope.$on('calcentral.api.updatedFeeds.services_with_updates', function() {
      $scope.has_updates = $scope.api.updatedFeeds.hasUpdates();
    });

    $scope.is_loading = false;
    $scope.$on('calcentral.api.updatedFeeds.is_loading', function() {
      $scope.is_loading = $scope.api.updatedFeeds.events.is_loading;
    });

    $scope.refreshFeeds = apiService.updatedFeeds.refreshFeeds;

  });

})(window.angular);
