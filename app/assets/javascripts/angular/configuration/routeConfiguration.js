/**
 * Configure the routes for CalCentral
 */
(function(calcentral) {

  'use strict';

  // Set the configuration
  calcentral.config(['$routeProvider', function($routeProvider) {

    // List all the routes
    $routeProvider.when('/', {
      templateUrl: 'templates/splash.html',
      controller: 'SplashController',
      isPublic: true
    }).
    // We actually need to duplicate the campus items, more info on
    // http://stackoverflow.com/questions/12524533
    when('/campus', {
      templateUrl: 'templates/campus.html',
      controller: 'CampusController'
    }).
    when('/campus/:category', {
      templateUrl: 'templates/campus.html',
      controller: 'CampusController'
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

  }]);

})(window.calcentral);
