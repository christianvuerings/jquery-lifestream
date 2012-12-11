(function() {
  /*global calcentral, angular*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('UpNextController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/up_next').success(function(data) {

      $scope.items = data.items;

      $scope.upnextToggleShow = function(dateitem) {
        dateitem.show = !dateitem.show;
      };

      $scope.containsOpen = function() {

        for(var i = 0; i < $scope.items.length; i++){
          if ($scope.items[i].show) {
            return true;
          }
        }
        return false;

      };

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
