(function(calcentral) {
  'use strict';

  /**
   * My Up Next controller
   */
  calcentral.controller('UpNextController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/up_next').success(function(data) {
      angular.extend($scope, data);
    });

  }]);

})(window.calcentral);
