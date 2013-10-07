(function(angular, calcentral) {
  'use strict';

  /**
   * Updated Feeds controller
   */
  calcentral.controller('UpdatedFeedsController', ['$scope', 'apiService', function($scope, apiService) {

    $scope.has_updates = false;
    $scope.$on('calcentral.api.updatedFeeds.services_with_updates', function(event, services) {
      $scope.has_updates = $scope.api.updatedFeeds.hasUpdates();
    });

    $scope.is_loading = false;
    $scope.$on('calcentral.api.updatedFeeds.is_loading', function(event, services) {
      $scope.is_loading = $scope.api.updatedFeeds.events.is_loading;
    });

    $scope.refreshFeeds = apiService.updatedFeeds.refreshFeeds;

  }]);

})(window.angular, window.calcentral);
