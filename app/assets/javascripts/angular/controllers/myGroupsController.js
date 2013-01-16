(function(calcentral) {
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('MyGroupsController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/groups').success(function(data) {

      $scope.mygroups = data.groups;

    });

  }]);

})(window.calcentral);
