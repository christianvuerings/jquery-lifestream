(function(calcentral) {
  'use strict';

  /**
   * Badges controller
   */

  calcentral.controller('BadgesController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/badges').success(function(data) {
      $scope.badges = data.badges;
    });

  }]);

})(window.calcentral);
