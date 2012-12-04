(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/classes').success(function(data) {

      $scope.myclasses = data;

    });

  }]);

})();
