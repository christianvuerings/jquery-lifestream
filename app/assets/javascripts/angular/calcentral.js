(function(window, angular) {

  'use strict';

  /**
   * CalCentral module
   */
  var calcentral = angular.module('calcentral', [
    'calcentral.services',
    'ngSanitize'
  ]);

  // Set the configuration
  calcentral.config(['$httpProvider', '$locationProvider', '$routeProvider', function($httpProvider, $locationProvider, $routeProvider) {

    // We set it to html5 mode so we don't have hash bang URLs
    $locationProvider.html5Mode(true).hashPrefix('!');

    // List all the routes
    $routeProvider.when('/', {
      templateUrl: 'templates/splash.html',
      controller: 'SplashController',
      isPublic: true
    }).
    when('/dashboard', {
      templateUrl: 'templates/dashboard.html',
      controller: 'DashboardController'
    }).
    when('/settings', {
      templateUrl: 'templates/settings.html',
      controller: 'SettingsController'
    }).

    // Redirect to a 404 page
    otherwise({
      templateUrl: 'templates/404.html',
      controller: 'ErrorController',
      isPublic: true
    });

    // Setting up CSRF tokens for POST, PUT and DELETE requests
    var document = window.document;
    var tokenElement = document.querySelector('meta[name=csrf-token]');
    if (tokenElement && tokenElement.content) {
      $httpProvider.defaults.headers.post['X-CSRF-Token'] = tokenElement.content;
      $httpProvider.defaults.headers.put['X-CSRF-Token'] = tokenElement.content;
    }

  }]);

  // Bind calcentral to the window object so it's globally accessible
  window.calcentral = calcentral;

})(window, window.angular);
