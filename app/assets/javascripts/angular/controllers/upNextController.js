(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('UpNextController', ['$http', '$scope', function($http, $scope) {

    $http.get('/dummy/upnext.json').success(function(data) {

      $scope.items = data.items;

      $scope.isAllDay = function(item) {
        // Filter for all-day calendar items, which have a "date" property
        return !!item.start.date;
      };

      $scope.notAllDay = function(item) {
        // Filter for timed calendar items, which have a "dateTime" property
        return !!item.start.date_time;
      };

    });

  }]);

})();
