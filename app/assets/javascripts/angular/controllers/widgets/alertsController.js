(function(angular) {
  'use strict';

  /**
   * Alerts controller
   */
  angular.module('calcentral.controllers').controller('AlertsController', function(badgesFactory, $scope) {

    var fetch = function() {
      badgesFactory.getBadges().success(function(data) {
        $scope.alert = data.alert;
      });
    };

    $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
      if (services && services['MyBadges::Merged']) {
        fetch({
          refreshCache: true
        });
      }
    });
    fetch();

  });

})(window.angular);
