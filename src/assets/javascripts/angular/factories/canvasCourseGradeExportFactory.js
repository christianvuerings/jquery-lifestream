(function(angular) {
  'use strict';

  /**
   * Canvas Course Add User Factory - Interface for 'Find a Person to Add' tool API endpoints
   */
  angular.module('calcentral.factories').factory('canvasCourseGradeExportFactory', function($http) {
    var exportOptions = function() {
      return $http.get('/api/academics/canvas/egrade_export/options');
    };

    return {
      exportOptions: exportOptions
    };
  });
}(window.angular));
