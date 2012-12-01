(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('UpNextController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/up_next').success(function(data) {

      $scope.items = data.items;

      $scope.isAllDay = function(item) {
        // Filter for all-day calendar items
        return !!item.is_all_day;
      };

      $scope.notAllDay = function(item) {
        // Filter for timed calendar items
        return !item.is_all_day;
      };

    });

  }]);

})();
