(function(window) {
  /*global calcentral*/
  'use strict';

  /**
   * CalCentral main controller
   */
  calcentral.controller('CalcentralController', ['$http', '$route', '$scope', function($http ,$route, $scope) {

    $scope.user = {};

    $scope.user.handleAccessToPage = function() {
      if (!$route.current.isPublic && !$scope.user.isAuthenticated()) {
        $scope.user.signIn();
      }
    };

    $scope.user.handleUserLoaded = function(data) {
      $scope.user.profile = data;
      $scope.user.handleAccessToPage();
    };

    $scope.user.fetch = function(){
      $http.get('/api/my/status').success($scope.user.handleUserLoaded);
    };

    $scope.user.isAuthenticated = function() {
      return ($scope.user.profile && $scope.user.profile.is_logged_in);
    };

    $scope.user.signIn = function() {
      window.location = '/login';
    };

    $scope.user.signOut = function() {
      window.location = '/logout';
    };

    $scope.$on('$routeChangeSuccess', function() {
      if(!$scope.user.profile) {
        $scope.user.fetch();
      } else {
        $scope.user.handleAccessToPage();
      }
      // Pass in controller name so we can set active location in menu
      $scope.controller_name = $route.current.controller;
    });

  }]);

})(window);
