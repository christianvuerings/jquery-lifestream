(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('userService', function($http, $location, $route, analyticsService, utilService) {

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
    var setFirstLogin = function() {
      profile.first_login_at = (new Date()).getTime();
    };

    /**
     * Handle the access to the page that the user is watching
     * This will depend on
     *   - whether they are logged in or not
     *   - whether the page is public
     */
    var handleAccessToPage = function() {
      // Redirect to the login page when the page is private and you aren't authenticated
      if (!$route.current.isPublic && !events.isAuthenticated) {
        analyticsService.trackEvent(['Authentication', 'Sign in - redirect to login']);
        signIn();
      // Record that you've already visited the calcentral once and redirect to the settings page on the first login
      } else if (events.isAuthenticated && !profile.first_login_at) {
        analyticsService.trackEvent(['Authentication', 'First login']);
        $http.post('/api/my/record_first_login').success(setFirstLogin);
      // Redirect to the dashboard when you're accessing the root page and are authenticated
      } else if (events.isAuthenticated && $location.path() === '/') {
        analyticsService.trackEvent(['Authentication', 'Redirect to dashboard']);
        utilService.redirect('dashboard');
      }
    };

    /**
     * Set the current user information
     */
    var handleUserLoaded = function(data) {
      angular.extend(profile, data);

      events.isLoaded = true;
      // Check whether the current user is authenticated or not
      events.isAuthenticated = profile && profile.is_logged_in;
      // Check whether the current user is authenticated and has a google access token
      events.isAuthenticatedAndHasGoogle = profile.is_logged_in && profile.has_google_access_token;
      // Expose the profile into events
      events.profile = profile;

      handleAccessToPage();
    };

    /**
     * Get the actual user information
     */
    var fetch = function(){
      $http.get('/api/my/status').success(handleUserLoaded);
    };

    var enableOAuth = function(authorizationService) {
      analyticsService.trackEvent(['OAuth', 'Enable', 'service: ' + authorizationService]);
      window.location = '/api/' + authorizationService + '/request_authorization';
    };

    var handleRouteChange = function() {

      // When we are in an iframe, we don't load fetch the user api
      // This will mean that isAuthenticated is still false so the refresh API will also not be called
      if (utilService.isInIframe()) {
        events.isLoaded = true;
        return;
      }

      if(!profile.features) {
        fetch();
      } else {
        handleAccessToPage();
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
      }).error(function(data, response_code) {
        if (response_code && response_code === 401) {
          // user is already logged out
          window.location = '/';
        }
      });
    };

    // Expose methods
    return {
      enableOAuth: enableOAuth,
      events: events,
      fetch: fetch,
      handleAccessToPage: handleAccessToPage,
      handleRouteChange: handleRouteChange,
      handleUserLoaded: handleUserLoaded,
      optOut: optOut,
      profile: profile,
      removeOAuth: removeOAuth,
      setFirstLogin: setFirstLogin,
      signIn: signIn,
      signOut: signOut
    };

  });

}(window.angular));
