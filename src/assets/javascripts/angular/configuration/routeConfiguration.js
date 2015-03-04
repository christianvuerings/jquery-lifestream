/**
 * Configure the routes for CalCentral
 */
(function(angular) {
  'use strict';

  // Set the configuration
  angular.module('calcentral.config').config(function($routeProvider) {
    // List all the routes
    $routeProvider.when('/', {
      templateUrl: 'splash.html',
      controller: 'SplashController',
      isPublic: true
    }).
    when('/academics', {
      templateUrl: 'academics.html',
      controller: 'AcademicsController'
    }).
    when('/academics/semester/:semesterSlug', {
      templateUrl: 'academics_semester.html',
      controller: 'AcademicsController'
    }).
    when('/academics/semester/:semesterSlug/class/:classSlug', {
      templateUrl: 'academics_classinfo.html',
      controller: 'AcademicsController'
    }).
    when('/academics/booklist/:semesterSlug', {
      templateUrl: 'academics_booklist.html',
      controller: 'AcademicsController'
    }).
    when('/academics/teaching-semester/:teachingSemesterSlug/class/:classSlug', {
      templateUrl: 'academics_classinfo.html',
      controller: 'AcademicsController'
    }).
    when('/campus/:category?', {
      templateUrl: 'campus.html',
      controller: 'CampusController'
    }).
    when('/dashboard', {
      templateUrl: 'dashboard.html',
      controller: 'DashboardController',
      fireUpdatedFeeds: true
    }).
    when('/finances', {
      templateUrl: 'myfinances.html',
      controller: 'MyFinancesController'
    }).
    when('/finances/details', {
      templateUrl: 'cars_details.html',
      controller: 'MyFinancesController'
    }).
    when('/settings', {
      templateUrl: 'settings.html',
      controller: 'SettingsController'
    }).
    when('/tools', {
      templateUrl: 'tools_index.html',
      controller: 'ToolsController'
    }).
    when('/tools/styles', {
      templateUrl: 'tools_styles.html',
      controller: 'StylesController'
    }).
    when('/uid_error', {
      templateUrl: 'uid_error.html',
      controller: 'uidErrorController',
      isPublic: true
    }).
    when('/canvas/embedded/rosters', {
      templateUrl: 'canvas_embedded/roster.html'
    }).
    when('/canvas/embedded/site_creation', {
      templateUrl: 'canvas_embedded/site_creation.html',
      controller: 'CanvasSiteCreationController',
      isEmbedded: true
    }).
    when('/canvas/embedded/create_course_site', {
      templateUrl: 'canvas_embedded/create_course_site.html',
      controller: 'CanvasCreateCourseSiteController',
      isEmbedded: true
    }).
    when('/canvas/embedded/create_project_site', {
      templateUrl: 'canvas_embedded/create_project_site.html',
      controller: 'CanvasCreateProjectSiteController',
      isEmbedded: true
    }).
    when('/canvas/embedded/user_provision', {
      templateUrl: 'canvas_embedded/user_provision.html',
      controller: 'CanvasUserProvisionController',
      isEmbedded: true
    }).
    when('/canvas/embedded/course_add_user', {
      templateUrl: 'canvas_embedded/course_add_user.html',
      controller: 'CanvasCourseAddUserController',
      isEmbedded: true
    }).
    when('/canvas/embedded/course_mediacasts', {
      templateUrl: 'canvas_embedded/course_mediacasts.html',
      isEmbedded: true
    }).
    when('/canvas/embedded/course_manage_official_sections', {
      templateUrl: 'canvas_embedded/course_manage_official_sections.html',
      controller: 'CanvasCourseManageOfficialSectionsController',
      isEmbedded: true
    }).
    when('/canvas/embedded/course_grade_export', {
      templateUrl: 'canvas_embedded/course_grade_export.html',
      controller: 'CanvasCourseGradeExportController',
      isEmbedded: true
    }).
    when('/canvas/rosters/:canvasCourseId', {
      templateUrl: 'canvas_embedded/roster.html'
    }).
    when('/canvas/site_creation', {
      templateUrl: 'canvas_embedded/site_creation.html',
      controller: 'CanvasSiteCreationController'
    }).
    when('/canvas/create_course_site', {
      templateUrl: 'canvas_embedded/create_course_site.html',
      controller: 'CanvasCreateCourseSiteController'
    }).
    when('/canvas/create_project_site', {
      templateUrl: 'canvas_embedded/create_project_site.html',
      controller: 'CanvasCreateProjectSiteController'
    }).
    when('/canvas/course_manage_official_sections/:canvasCourseId', {
      templateUrl: 'canvas_embedded/course_manage_official_sections.html',
      controller: 'CanvasCourseManageOfficialSectionsController'
    }).
    when('/canvas/user_provision', {
      templateUrl: 'canvas_embedded/user_provision.html',
      controller: 'CanvasUserProvisionController'
    }).
    when('/canvas/course_add_user/:canvasCourseId', {
      templateUrl: 'canvas_embedded/course_add_user.html',
      controller: 'CanvasCourseAddUserController'
    }).
    when('/canvas/course_mediacasts/:canvasCourseId', {
      templateUrl: 'canvas_embedded/course_mediacasts.html'
    }).
    // Redirect to a 404 page
    otherwise({
      templateUrl: '404.html',
      controller: 'ErrorController',
      isPublic: true
    });
  });
})(window.angular);
