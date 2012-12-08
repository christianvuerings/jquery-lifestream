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
      } else if ($scope.user.isAuthenticated() && !$scope.user.profile.first_login_at) {
        $http.post('/api/my/record_first_login').success(function(data){
          window.location = '/profile';
        });
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

    /**
     * Remove OAuth permissions for a service for the currently logged in user
     * @param {String} authorizationService The authorization service (e.g. 'google')
     */
    $scope.user.removeOAuth = function(authorizationService) {
      // Send the request to remove the authorization for the specific OAuth service
      // Only when the request was successful, we update the UI
      $http.post('/api/' + authorizationService + '/remove_authorization').success(function(){
        $scope.user.profile['has_' + authorizationService + '_access_token'] = false;
      });
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
