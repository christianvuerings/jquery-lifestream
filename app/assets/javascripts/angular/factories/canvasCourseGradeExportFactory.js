/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Course Add User Factory - Interface for 'Find a Person to Add' tool API endpoints
   */
  angular.module('calcentral.factories').factory('canvasCourseGradeExportFactory', function($http) {
    var checkAuthorization = function() {
      return $http.get('/api/academics/canvas/course_user_roles');
    }

    var exportOptions = function() {
      return $http.get('/api/academics/canvas/egrade_export/options');
    };

    return {
      checkAuthorization: checkAuthorization,
      exportOptions: exportOptions,
    };

  });
}(window.angular));
