/**
 * Configure the routes for CalCentral
 */
(function(angular) {

  'use strict';

  // Set the configuration
  angular.module('calcentral.config').config(function($routeProvider) {

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
    when('/academics/semester/:semesterSlug', {
      templateUrl: 'templates/academics_semester.html',
      controller: 'AcademicsController'
    }).
    when('/academics/semester/:semesterSlug/class/:classSlug', {
      templateUrl: 'academics_classinfo.html',
      controller: 'AcademicsController'
    }).
    when('/academics/booklist', {
      templateUrl: 'academics_booklist.html',
      controller: 'AcademicsController'
    }).
    when('/academics/teaching-semester/:teachingSemesterSlug/class/:classSlug', {
      templateUrl: 'academics_classinfo.html',
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
      fireUpdatedFeeds: true
    }).
    when('/finances', {
      templateUrl: 'templates/myfinances.html',
      controller: 'MyFinancesController'
    }).
    when('/profile', {
      templateUrl: 'templates/profile.html',
      controller: 'ProfileController'
    }).
    when('/finances/details', {
      templateUrl: 'cars_details.html',
      controller: 'MyFinancesController'
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
    when('/uid_error', {
      templateUrl: 'templates/uid_error.html',
      controller: 'uidErrorController',
      isPublic: true
    }).
    when('/canvas/embedded/rosters', {
      templateUrl: 'templates/canvas_embedded/roster.html'
    }).
    when('/canvas/embedded/course_provision_account_navigation', {
      templateUrl: 'templates/canvas_embedded/course_provision.html',
      controller: 'CanvasCourseProvisionController'
    }).
    when('/canvas/embedded/course_provision_user_navigation', {
      templateUrl: 'templates/canvas_embedded/course_provision.html',
      controller: 'CanvasCourseProvisionController'
    }).
    when('/canvas/embedded/user_provision', {
      templateUrl: 'templates/canvas_embedded/user_provision.html',
      controller: 'CanvasUserProvisionController'
    }).
    when('/canvas/embedded/course_add_user', {
      templateUrl: 'templates/canvas_embedded/course_add_user.html',
      controller: 'CanvasCourseAddUserController'
    }).
    when('/canvas/embedded/course_mediacasts', {
      templateUrl: 'templates/canvas_embedded/course_mediacasts.html',
      isEmbedded: true
    }).
    when('/canvas/rosters/:canvasCourseId', {
      templateUrl: 'templates/canvas_embedded/roster.html'
    }).
    when('/canvas/course_provision', {
      templateUrl: 'templates/canvas_embedded/course_provision.html',
      controller: 'CanvasCourseProvisionController'
    }).
    when('/canvas/user_provision', {
      templateUrl: 'templates/canvas_embedded/user_provision.html',
      controller: 'CanvasUserProvisionController'
    }).
    when('/canvas/course_add_user/:canvas_course_id', {
      templateUrl: 'templates/canvas_embedded/course_add_user.html',
      controller: 'CanvasCourseAddUserController'
    }).
    when('/canvas/course_mediacasts/:canvasCourseId', {
      templateUrl: 'templates/canvas_embedded/course_mediacasts.html'
    }).
    // Redirect to a 404 page
    otherwise({
      templateUrl: 'templates/404.html',
      controller: 'ErrorController',
      isPublic: true
    });

  });

})(window.angular);
