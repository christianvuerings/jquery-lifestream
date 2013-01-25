(function(calcentral) {
  'use strict';

  /**
   * My Classes controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/classes').success(function(data) {
      $scope.myclasses = data.classes;
    });

  }]);

})(window.calcentral);
