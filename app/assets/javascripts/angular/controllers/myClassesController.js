(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', function($http, $scope) {

    $http.get('/dummy/myclasses.json').success(function(data) {

      $scope.myclasses = data;

    });

  }]);

})();
