(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Preferences controller
   */
  calcentral.controller('ProfileController', ['$rootScope', '$http', '$scope', function($rootScope, $http, $scope) {

    $http.get('/dummy/mystatus.json').success(function(data) {
      $scope.status = data;
    });

    $rootScope.title = 'Profile | CalCentral';

  }]);

})();
