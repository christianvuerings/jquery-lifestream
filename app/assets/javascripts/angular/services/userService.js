(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('userService', function($http, $location, $route, analyticsService, httpService, utilService) {

    var profile = {};
    var events = {
      isLoaded: false,
      isAuthenticated: false,
      isAuthenticatedAndHasGoogle: false,
      profile: false
    };
    var statusUrl = '/api/my/status';

    // Private methods that are only exposed for testing but shouldn't be used within the views

    /**
     * Opt in for a student to see the course schedule on the calendar
     */
    var calendarOptIn = function() {
      $http.post('/api/my/calendar/opt_in').success(function() {
        analyticsService.sendEvent('Calendar Courses', 'Enable');
        fetch();
      });
    };

    /**
     * Opt out for a student to see the course schedule on the calendar
     */
    var calendarOptOut = function() {
      $http.post('/api/my/calendar/opt_out').success(function() {
        analyticsService.sendEvent('Calendar Courses', 'Remove');
        fetch();
      });
    };

    /**
     * Redirect user to the dashboard when you're on the splash page
     */
    var redirectToDashboard = function() {
      if ($location.path() === '/') {
        analyticsService.sendEvent('Authentication', 'Redirect to dashboard');
        utilService.redirect('dashboard');
      }
    };

    /**
     * Set the user firstLoginAt attribute
     */
    var setFirstLogin = function() {
      profile.firstLoginAt = (new Date()).getTime();
      redirectToDashboard();
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
        analyticsService.sendEvent('Authentication', 'Sign in - redirect to login');
        signIn();
      // Record that the user visited calcentral
      } else if (events.isAuthenticated && !profile.firstLoginAt && !profile.actingAsUid) {
        analyticsService.sendEvent('Authentication', 'First login');
        $http.post('/api/my/record_first_login').success(setFirstLogin);
      // Redirect to the dashboard when you're accessing the root page and are authenticated
      } else if (events.isAuthenticated) {
        redirectToDashboard();
      }
    };

    /**
     * Set the current user information
     */
    var handleUserLoaded = function(data) {
      angular.extend(profile, data);

      events.isLoaded = true;
      // Check whether the current user is authenticated or not
      events.isAuthenticated = profile && profile.isLoggedIn;
      // Check whether the current user is authenticated and has a google access token
      events.isAuthenticatedAndHasGoogle = profile.isLoggedIn && profile.hasGoogleAccessToken;
      // Expose the profile into events
      events.profile = profile;

      handleAccessToPage();
    };

    /**
     * Get the actual user information
     * @param {Object} options Options that need to be passed through
     */
    var fetch = function(options) {

      httpService.clearCache(options, statusUrl);

      return $http.get(statusUrl, {
        cache: true
      }).then(function(xhr) {
        return handleUserLoaded(xhr.data);
      });
    };

    var enableOAuth = function(authorizationService) {
      analyticsService.sendEvent('OAuth', 'Enable', 'service: ' + authorizationService);
      window.location = '/api/' + authorizationService.toLowerCase() + '/request_authorization';
    };

    var handleRouteChange = function() {
      if (!profile.features) {
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
        analyticsService.sendEvent('Settings', 'User opt-out');
        signOut();
      });
    };

    /**
     * Sign the current user in.
     */
    var signIn = function() {
      analyticsService.sendEvent('Authentication', 'Redirect to login');
      window.location = '/auth/cas';
    };

    /**
     * Remove OAuth permissions for a service for the currently logged in user
     * @param {String} authorizationService The authorization service (e.g. 'google')
     */
    var removeOAuth = function(authorizationService) {
      // Send the request to remove the authorization for the specific OAuth service
      // Only when the request was successful, we update the UI
      $http.post('/api/' + authorizationService.toLowerCase() + '/remove_authorization').success(function() {
        analyticsService.sendEvent('OAuth', 'Remove', 'service: ' + authorizationService);
        profile['has' + authorizationService + 'AccessToken'] = false;
      });
    };

    /**
     * Sign the current user out.
     */
    var signOut = function() {
      $http.post('/logout').success(function(data) {
        if (data && data.redirectUrl) {
          analyticsService.sendEvent('Authentication', 'Redirect to logout');
          window.location = data.redirectUrl;
        }
      }).error(function(data, responseCode) {
        if (responseCode && responseCode === 401) {
          // user is already logged out
          window.location = '/';
        }
      });
    };

    // Expose methods
    return {
      calendarOptIn: calendarOptIn,
      calendarOptOut: calendarOptOut,
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
