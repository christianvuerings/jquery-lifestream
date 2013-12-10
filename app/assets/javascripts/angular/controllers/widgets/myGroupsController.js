(function(angular) {
  'use strict';

  /**
   * My Groups controller
   */
  angular.module('calcentral.controllers').controller('MyGroupsController', function(apiService, $http, $scope) {

    var getMyGroups = function() {
      $http.get('/api/my/groups').success(function(data) {
        apiService.updatedFeeds.feedLoaded(data);
        angular.extend($scope, data);
      });
    };

    $scope.$on('calcentral.api.updatedFeeds.update_services', function(event, services) {
      if (services && services.MyGroups) {
        getMyGroups();
      }
    });
    getMyGroups();
  });

})(window.angular);
