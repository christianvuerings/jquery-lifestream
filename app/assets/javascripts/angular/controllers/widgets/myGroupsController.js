(function(calcentral) {
  'use strict';

  /**
   * My Groups controller
   */
  calcentral.controller('MyGroupsController', ['$http', '$scope', function($http, $scope) {

    var getMyGroups = function() {
      $http.get('/api/my/groups').success(function(data) {
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
