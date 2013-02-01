(function(window, calcentral) {
  'use strict';

  /**
   * CalCentral main controller
   */
  calcentral.controller('CalcentralController', ['$http', '$location', '$route', '$scope', 'analyticsService', function($http, $location, $route, $scope, analyticsService) {

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
     * Handle the access to the page that the user is watching
     * This will depend on
     *   - whether they are logged in or not
     *   - whether the page is public
     */
    $scope.user._handleAccessToPage = function() {
      // Redirect to the login page when the page is private and you aren't authenticated
      if (!$route.current.isPublic && !$scope.user.isAuthenticated()) {
        analyticsService.trackEvent(['Authentication', 'Sign in - redirect to login']);
        $scope.user.signIn();
      // Record that you've already visited the calcentral once and redirect to the settings page on the first login
      } else if ($scope.user.isAuthenticated() && !$scope.user.profile.first_login_at) {
        analyticsService.trackEvent(['Authentication', 'First login']);
        $http.post('/api/my/record_first_login').success($scope.user._redirectToSettingsPage);
      // Redirect to the dashboard when you're accessing the root page and are authenticated
      } else if ($scope.user.isAuthenticated() && $location.path() === '/') {
        analyticsService.trackEvent(['Authentication', 'Redirect to dashboard']);
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
      analyticsService.trackEvent(['OAuth', 'Remove', 'service: ' + authorizationService]);
    };

    $scope.user.enableOAuth = function(authorizationService) {
      analyticsService.trackEvent(['OAuth', 'Enable', 'service: ' + authorizationService]);
      window.location = '/api/' + authorizationService + '/request_authorization';
    };

    /**
     * Sign the current user in.
     */
    $scope.user.signIn = function() {
      analyticsService.trackEvent(['Authentication', 'Redirect to login']);
      window.location = '/login';
    };

    /**
     * Sign the current user out.
     */
    $scope.user.signOut = function() {
      analyticsService.trackEvent(['Authentication', 'Redirect to logout']);
      window.location = '/logout';
    };

    /**
     * Opt-out.
     */
    $scope.user.optOut = function() {
      analyticsService.trackEvent(['Settings', 'User opt-out']);
      window.location = "/api/my/opt_out";
    };

    // API
    $scope.api = {};

    // Widgets
    $scope.api.widget = {};

    /**
     * Toggle whether an item for a widget should be shown or not
     */
    $scope.api.widget.toggleShow = function(item, widget) {
      item.show = !item.show;
      analyticsService.trackEvent(['Detailed view', item.show ? 'Open' : 'Close', widget]);
    };

    /**
     * Check whether there is one item in the list that is shown
     * @return {Boolean} Will be true when there is one item in the list that is shown
     */
    $scope.api.widget.containsOpen = function(items) {
      if (!items) {
        return;
      }

      for(var i = 0; i < items.length; i++){
        if (items[i].show) {
          return true;
        }
      }
      return false;
    };

    // Util
    $scope.api.util = {};

    /**
     * Prevent a click event from bubbling up to its parents
     */
    $scope.api.util.preventBubble = function($event) {
      $event.stopPropagation();
    };

    /**
     * Expose the externalLink function to the view
     */
    $scope.api.util.trackExternalLink = analyticsService.trackExternalLink;

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

  }]);

})(window, window.calcentral);
