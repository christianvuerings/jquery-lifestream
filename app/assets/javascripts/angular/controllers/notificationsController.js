(function(calcentral) {
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('NotificationsController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/notifications').success(function(data) {
      $scope.notifications = data.notifications;
    });

  }]);

})(window.calcentral);
