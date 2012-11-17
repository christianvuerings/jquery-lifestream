(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('MyGroupsController', ['$http', '$scope', function($http, $scope) {

    $http.get('/dummy/mygroups.json').success(function(data) {

      $scope.mygroups = data;

    });

  }]);

})();
