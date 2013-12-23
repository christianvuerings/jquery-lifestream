(function(angular) {
  'use strict';

  /**
   * Basic Authentication controller
   */
  angular.module('calcentral.controllers').controller('BasicAuthController', function($http, $scope) {

    $scope.basicauth = {
      user: null
    };

    $scope.basicauth.connect = function() {
      $http.get('/basic_auth_login').success(function(data, status) {
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
      if (window.btoa) {
        $http.defaults.headers.common.Authorization = 'Basic ' + btoa($scope.basicauth.login + ':' + $scope.basicauth.password);
      }
    });

  });

})(window.angular);
