(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('NotificationsController', ['$http', '$scope', function($http, $scope) {

    $http.get('/dummy/notifications.json').success(function(data) {

      $scope.notifications = data.notifications;

    });

  }]);

})();
