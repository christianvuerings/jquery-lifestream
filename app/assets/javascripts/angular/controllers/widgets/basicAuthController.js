(function(angular) {
  'use strict';

  /**
   * Basic Authentication controller
   */
  angular.module('calcentral.controllers').controller('BasicAuthController', function(basicAuthFactory, $scope) {
    $scope.basicauth = {
      user: null
    };

    $scope.basicauth.connect = function() {
      basicAuthFactory.login().success(function(data, status) {
        if (status < 200 || status >= 300) {
          return;
        }
        $scope.basicauth.user = data;
        window.location = '/';
      });
    };

    $scope.basicauth.disconnect = function() {
      $scope.basicauth.user = null;
    };

    $scope.$watch('basicauth.login + basicauth.password', function() {
      basicAuthFactory.updateHeaders($scope.basicauth);
    });
  });
})(window.angular);
