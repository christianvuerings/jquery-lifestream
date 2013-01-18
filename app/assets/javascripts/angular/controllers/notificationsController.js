(function(calcentral) {
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('NotificationsController', ['$http', '$scope', function($http, $scope) {

    /*TODO uncomment as soon as we are able to show the nofications
      $http.get('/dummy/json/notifications.json').success(function(data) {

        $scope.notifications = data.notifications;

      });
     */

    $scope.notifications = {};

  }]);

})(window.calcentral);
