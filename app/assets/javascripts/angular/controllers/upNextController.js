(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('UpNextController', ['$http', '$scope', function($http, $scope) {

    $http.get('/dummy/upnext.json').success(function(data) {

      $scope.items = data.items;

    });

  }]);

})();
