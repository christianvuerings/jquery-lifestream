(function(window, calcentral) {
  'use strict';

  /**
   * CalCentral main controller
   */
  calcentral.controller('CalcentralController', ['$http', '$location', '$route', '$scope', 'apiService', function($http, $location, $route, $scope, apiService) {

    $scope.user = {
      'isLoaded': false
    };

    // Private methods that are only exposed for testing but shouldn't be used within the views

    /**
     * Redirect to the settings page
     */
    $scope.user._redirectToSettingsPage = function() {
      $location.path('/settings');
    };

    /**
     * Redirect to the dashboard page
     */
    $scope.user._redirectToDashboardPage = function() {
      $location.path('/dashboard');
    };

    /**
     * Set the user first_login_at attribute and redirect to the settings page
     */
    $scope.user._setFirstLogin = function() {
      $scope.user.profile.first_login_at = (new Date()).getTime();
      $scope.user._redirectToSettingsPage();
    };

    /**
     * Handle the access to the page that the user is watching
     * This will depend on
     *   - whether they are logged in or not
     *   - whether the page is public
     */
    $scope.user._handleAccessToPage = function() {
      // Redirect to the login page when the page is private and you aren't authenticated
      if (!$route.current.isPublic && !$scope.user.isAuthenticated()) {
        apiService.analytics.trackEvent(['Authentication', 'Sign in - redirect to login']);
        $scope.user.signIn();
      // Record that you've already visited the calcentral once and redirect to the settings page on the first login
      } else if ($scope.user.isAuthenticated() && !$scope.user.profile.first_login_at) {
        apiService.analytics.trackEvent(['Authentication', 'First login']);
        $http.post('/api/my/record_first_login').success($scope.user._setFirstLogin);
      // Redirect to the dashboard when you're accessing the root page and are authenticated
      } else if ($scope.user.isAuthenticated() && $location.path() === '/') {
        apiService.analytics.trackEvent(['Authentication', 'Redirect to dashboard']);
        $scope.user._redirectToDashboardPage();
      }
    };

    /**
     * Set the current user information
     */
    $scope.user._handleUserLoaded = function(data) {
      $scope.user.profile = data;
      $scope.user._handleAccessToPage();
      $scope.user.isLoaded = true;
    };

    /**
     * Get the actual user information
     */
    $scope.user._fetch = function(){
      $http.get('/api/my/status').success($scope.user._handleUserLoaded);
    };

    /**
     * Check whether the current user is authenticated or not
     * @return {Boolean} True when the user is authenticated
     */
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
      apiService.analytics.trackEvent(['OAuth', 'Remove', 'service: ' + authorizationService]);
    };

    $scope.user.enableOAuth = function(authorizationService) {
      apiService.analytics.trackEvent(['OAuth', 'Enable', 'service: ' + authorizationService]);
      window.location = '/api/' + authorizationService + '/request_authorization';
    };

    /**
     * Sign the current user in.
     */
    $scope.user.signIn = function() {
      apiService.analytics.trackEvent(['Authentication', 'Redirect to login']);
      window.location = '/login';
    };

    /**
     * Sign the current user out.
     */
    $scope.user.signOut = function() {
      $http.post('/logout').success(function(data) {
        if (data && data.redirect_url) {
          apiService.analytics.trackEvent(['Authentication', 'Redirect to logout']);
          window.location = data.redirect_url;
        }
      });
    };

    /**
     * Opt-out.
     */
    $scope.user.optOut = function() {
      $http.post('/api/my/opt_out').success(function() {
        apiService.analytics.trackEvent(['Settings', 'User opt-out']);
        $scope.user.signOut();
      });
    };

    /**
     * Will be executed on every route change
     *  - Get the user information when it hasn't been loaded yet
     *  - Handle the page access
     *  - Send the right controller name
     */
    $scope.$on('$routeChangeSuccess', function() {
      if(!$scope.user.profile) {
        $scope.user._fetch();
      } else {
        $scope.user._handleAccessToPage();
      }
      // Pass in controller name so we can set active location in menu
      $scope.controller_name = $route.current.controller;
    });

    $scope.api = apiService;

  }]);

})(window, window.calcentral);
