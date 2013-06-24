(function(calcentral) {
  'use strict';

  /**
   * My Classes controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', function($http, $scope) {

    var getMyClasses = function() {
      $http.get('/api/my/classes').success(function(data) {
        angular.extend($scope, data);
      });
    };

    $scope.$on('calcentral.api.refresh.refreshed', function() {
      getMyClasses();
    });

  }]);

})(window.calcentral);
