(function(angular) {
  'use strict';

  /**
   * My Groups controller
   */
  angular.module('calcentral.controllers').controller('MyGroupsController', function(apiService, myGroupsFactory, $routeParams, $scope) {
    var getMyGroups = function(options) {
      myGroupsFactory.getGroups(options).success(function(data) {
        apiService.updatedFeeds.feedLoaded(data);
        angular.extend($scope, data);
      });
    };

    $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
      if (services && services['MyGroups::Merged']) {
        getMyGroups({
          refreshCache: true
        });
      }
    });
    getMyGroups();
  });
})(window.angular);
