(function(angular) {
  'use strict';

  /**
   * My Up Next controller
   */
  angular.module('calcentral.controllers').controller('UpNextController', function(apiService, $http, $scope) {

    /**
     * Make sure that we're not showing wrong date information to the user.
     * This will make sure that the date that is shown in the UI is the
     * same as the last modified date of the feed.
     * @param {Integer} epoch Last modified date epoch
     */
    var setLastModifiedDate = function(epoch) {
      $scope.lastModifiedDate = new Date(epoch * 1000);
    };

    var getUpNext = function() {
      $http.get('/api/my/up_next').success(function(data) {
        apiService.updatedFeeds.feedLoaded(data);
        angular.extend($scope, data);
        setLastModifiedDate(data.last_modified.timestamp.epoch);
      });
    };

    $scope.$on('calcentral.api.updatedFeeds.update_services', function(event, services) {
      if (services && services.MyUpNext) {
        getUpNext();
      }
    });
    getUpNext();

  });

})(window.angular);
