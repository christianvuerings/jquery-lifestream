(function(calcentral) {
  'use strict';

  /**
   * Badges controller
   */

  calcentral.controller('BadgesController', ['$http', '$scope', function($http, $scope) {

    $http.get('/dummy/json/badges.json').success(function(data) {
      $scope.unread_badge_counts = data.unread_badge_counts;
    });

  }]);

})(window.calcentral);
