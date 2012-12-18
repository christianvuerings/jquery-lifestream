(function() {
  /*global calcentral */
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('UpNextController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/up_next').success(function(data) {

      $scope.items = data.items;

    });

  }]);

})();
