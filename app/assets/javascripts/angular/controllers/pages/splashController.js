(function(angular) {
  'use strict';

  /**
   * Splash controller
   */
  angular.module('calcentral.controllers').controller('SplashController', function($filter, $http, $scope, apiService) {

    apiService.util.setTitle('Home');

    $http.get('/api/blog/release_notes/latest').success(function(data) {
      if ($scope.splashNote) {
        return;
      }
      $scope.splashNote = data.entries[0];
    });

    $scope.$watch('api.user.profile.alert', function watchAlert(alert) {
      if (!alert) {
        return;
      }
      $scope.splashNote = {
        date: $filter('date')(alert.timestamp.epoch * 1000, 'MMM dd'),
        link: alert.url,
        snippet: alert.teaser,
        title: alert.title
      };
    });

  });

})(window.angular);
