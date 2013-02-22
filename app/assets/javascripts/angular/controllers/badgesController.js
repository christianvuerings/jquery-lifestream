(function(calcentral) {
  'use strict';

  /**
   * Badges controller
   */

  calcentral.controller('BadgesController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/badges').success(function(data) {
      $scope.unread_badge_counts = data.unread_badge_counts;
    });

  }]);

})(window.calcentral);
