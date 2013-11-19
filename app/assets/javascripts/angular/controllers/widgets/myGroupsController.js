(function(calcentral) {
  'use strict';

  /**
   * My Groups controller
   */
  calcentral.controller('MyGroupsController', [
    'apiService',
    '$http',
    '$scope',
    function(
      apiService,
      $http,
      $scope) {

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
  }]);

})(window.calcentral);
