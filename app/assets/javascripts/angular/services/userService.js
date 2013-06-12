(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('userService', [
    '$http',
    '$location',
    '$route',
    'analyticsService',
    'utilService',
    function(
      $http,
      $location,
      $route,
      analyticsService,
      utilService) {

    var profile = {};
    var events = {
      isLoaded: false,
      isAuthenticated: false,
      isAuthenticatedAndHasGoogle: false,
      profile: false
    };

    // Private methods that are only exposed for testing but shouldn't be used within the views

    /**
     * Set the user first_login_at attribute and redirect to the settings page
     */
    var _setFirstLogin = function() {
      profile.first_login_at = (new Date()).getTime();
      utilService.redirect('settings');
    };

    /**
     * Handle the access to the page that the user is watching
     * This will depend on
     *   - whether they are logged in or not
     *   - whether the page is public
     */
    var _handleAccessToPage = function() {
      // Redirect to the login page when the page is private and you aren't authenticated
      if (!$route.current.isPublic && !events.isAuthenticated) {
        analyticsService.trackEvent(['Authentication', 'Sign in - redirect to login']);
        signIn();
      // Record that you've already visited the calcentral once and redirect to the settings page on the first login
      } else if (events.isAuthenticated && !profile.first_login_at) {
        analyticsService.trackEvent(['Authentication', 'First login']);
        $http.post('/api/my/record_first_login').success(_setFirstLogin);
      // Redirect to the dashboard when you're accessing the root page and are authenticated
      } else if (events.isAuthenticated && $location.path() === '/') {
        analyticsService.trackEvent(['Authentication', 'Redirect to dashboard']);
        utilService.redirect('dashboard');
      }
    };

    /**
     * Set the current user information
     */
    var _handleUserLoaded = function(data) {
      angular.extend(profile, data);

      events.isLoaded = true;
      // Check whether the current user is authenticated or not
      events.isAuthenticated = profile && profile.is_logged_in;
      // Check whether the current user is authenticated and has a google access token
      events.isAuthenticatedAndHasGoogle = profile.is_logged_in && profile.has_google_access_token;
      // Expose the profile into events
      events.profile = profile;

      _handleAccessToPage();
    };

    /**
     * Get the actual user information
     */
    var _fetch = function(){
      $http.get('/api/my/status').success(_handleUserLoaded);
    };

    var enableOAuth = function(authorizationService) {
      analyticsService.trackEvent(['OAuth', 'Enable', 'service: ' + authorizationService]);
      window.location = '/api/' + authorizationService + '/request_authorization';
    };

    var handleRouteChange = function() {
      if(!profile.features) {
        _fetch();
      } else {
        _handleAccessToPage();
      }
    };

    /**
     * Opt-out.
     */
    var optOut = function() {
      $http.post('/api/my/opt_out').success(function() {
        analyticsService.trackEvent(['Settings', 'User opt-out']);
        signOut();
      });
    };

    /**
     * Sign the current user in.
     */
    var signIn = function() {
      analyticsService.trackEvent(['Authentication', 'Redirect to login']);
      window.location = '/login';
    };

    /**
     * Remove OAuth permissions for a service for the currently logged in user
     * @param {String} authorizationService The authorization service (e.g. 'google')
     */
    var removeOAuth = function(authorizationService) {
      // Send the request to remove the authorization for the specific OAuth service
      // Only when the request was successful, we update the UI
      $http.post('/api/' + authorizationService + '/remove_authorization').success(function(){
        analyticsService.trackEvent(['OAuth', 'Remove', 'service: ' + authorizationService]);
        profile['has_' + authorizationService + '_access_token'] = false;
      });
    };

    /**
     * Sign the current user out.
     */
    var signOut = function() {
      $http.post('/logout').success(function(data) {
        if (data && data.redirect_url) {
          analyticsService.trackEvent(['Authentication', 'Redirect to logout']);
          window.location = data.redirect_url;
        }
      });
    };

    // Expose methods
    return {
      _setFirstLogin: _setFirstLogin,
      _handleAccessToPage: _handleAccessToPage,
      _handleUserLoaded: _handleUserLoaded,
      _fetch: _fetch,
      enableOAuth: enableOAuth,
      events: events,
      handleRouteChange: handleRouteChange,
      optOut: optOut,
      profile: profile,
      removeOAuth: removeOAuth,
      signIn: signIn,
      signOut: signOut
    };

  }]);

}(window.angular));
