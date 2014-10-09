(function(angular) {
  'use strict';

  /**
   * Splash controller
   */
  angular.module('calcentral.controllers').controller('SplashController', function(apiService, blogFactory, $filter, $scope) {
    apiService.util.setTitle('Home');

    blogFactory.getBlog().success(function(data) {
      if (data.alert && data.alert.title) {
        $scope.splashNote = {
          date: $filter('date')(data.alert.timestamp.epoch * 1000, 'MMM dd'),
          link: data.alert.url,
          snippet: data.alert.teaser,
          title: data.alert.title
        };
      } else {
        $scope.splashNote = data.entries[0];
      }
    });
  });
})(window.angular);
