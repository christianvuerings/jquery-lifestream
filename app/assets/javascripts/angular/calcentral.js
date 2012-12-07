(function(window) {

  /*global angular*/
  'use strict';

  /**
   * CalCentral module
   */
  var calcentral = angular.module('calcentral', []);

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
    when('/profile', {
      templateUrl: 'templates/profile.html',
      controller: 'ProfileController'
    }).

    // Redirect to a 404 page
    otherwise({
      templateUrl: 'templates/404.html',
      controller: 'ErrorController',
      isPublic: true
    });

    // Setting up CSRF tokens for POST, PUT and DELETE requests
    var token = document.querySelector('meta[name=csrf-token]').content;
    $httpProvider.defaults.headers.post['X-CSRF-Token'] = token;
    $httpProvider.defaults.headers.put['X-CSRF-Token'] = token;

  }]);

  // Bind calcentral to the window object so it's globally accessible
  window.calcentral = calcentral;

})(window);
