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
    when('/academics', {
      templateUrl: 'templates/academics.html',
      controller: 'AcademicsController'
    }).
    when('/academics/semester/:semester_slug', {
      templateUrl: 'templates/academics_semester.html',
      controller: 'AcademicsController'
    }).
    when('/academics/semester/:semester_slug/class/:class_slug', {
      templateUrl: 'templates/academics_classinfo.html',
      controller: 'AcademicsController'
    }).
    when('/academics/teaching-semester/:teaching_semester_slug/class/:class_slug', {
      templateUrl: 'templates/academics_classinfo.html',
      controller: 'AcademicsController'
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
      controller: 'DashboardController',
      shouldRefresh: true
    }).
    when('/settings', {
      templateUrl: 'templates/settings.html',
      controller: 'SettingsController'
    }).
    when('/tools', {
      templateUrl: 'templates/tools_index.html',
      controller: 'ToolsController'
    }).
    when('/tools/styles', {
      templateUrl: 'templates/tools_styles.html',
      controller: 'StylesController'
    }).
    when('/sorry', {
      templateUrl: 'templates/sorry.html',
      controller: 'SorryController',
      isPublic: true
    }).
    when('/canvas/embedded/rosters', {
      templateUrl: 'templates/canvas_embedded/roster.html',
      controller: 'CanvasEmbeddedController'
    }).
    when('/canvas/rosters/:canvas_course_id', {
      templateUrl: 'templates/canvas_embedded/roster.html',
      controller: 'CanvasEmbeddedController'
    }).
    // Redirect to a 404 page
    otherwise({
      templateUrl: 'templates/404.html',
      controller: 'ErrorController',
      isPublic: true
    });

  }]);

})(window.calcentral);
