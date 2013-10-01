(function(calcentral) {
  'use strict';

  /**
   * My Up Next controller
   */
  calcentral.controller('UpNextController', ['$http', '$scope', function($http, $scope) {

    var getUpNext = function() {
      $http.get('/api/my/up_next').success(function(data) {
        angular.extend($scope, data);
      });
    };

    $scope.$on('calcentral.api.updatedFeeds.update_services', function(event, services) {
      if (services && services.MyUpNext) {
        getUpNext();
      }
    });
    getUpNext();

  }]);

})(window.calcentral);
