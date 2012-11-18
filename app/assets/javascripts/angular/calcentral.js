(function(window) {

  /*global angular*/
  'use strict';

  /**
   * CalCentral module
   */
  var calcentral = angular.module('calcentral', []);

  // Set the configuration
  calcentral.config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {

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

    // Redirect to a 404 page
    otherwise({
      templateUrl: 'templates/404.html',
      controller: 'ErrorController',
      isPublic: true
    });

  }]);

  // Bind calcentral to the window object so it's globally accessible
  window.calcentral = calcentral;

})(window);
