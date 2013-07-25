(function(calcentral) {
  'use strict';

  /**
   * My Groups controller
   */
  calcentral.controller('MyGroupsController', ['$http', '$scope', function($http, $scope) {

    var excludeClasses = function(data) {
      if (data.groups) {
        data.groups = data.groups.filter(function(value) {
          return (!value.site_type || value.site_type !== 'course')
        });
      }
    };

    var getMyGroups = function() {
      $http.get('/api/my/groups').success(function(data) {
        excludeClasses(data);
        angular.extend($scope, data);
      });
    };

    $scope.$on('calcentral.api.refresh.refreshed', function() {
      getMyGroups();
    });

  }]);

})(window.calcentral);