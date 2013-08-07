(function(calcentral) {
  'use strict';

  /**
   * Footer controller
   */
  calcentral.controller('FooterController', ['$http', '$scope', function($http, $scope) {

    $scope.footer = {
      showInfo: false
    };

    var loadServerInformation = function() {
      $http.get('/api/server_info').success(function(data) {
        angular.extend($scope, data);
      });
    };

    $scope.$watch('footer.showInfo', function(showInfo) {
      if (showInfo && !$scope.versions) {
        loadServerInformation();
      }
    });

  }]);

})(window.calcentral);
