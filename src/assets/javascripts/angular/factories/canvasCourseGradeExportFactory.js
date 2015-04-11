(function(angular) {
  'use strict';

  /**
   * Canvas Course Add User Factory - Interface for 'Find a Person to Add' tool API endpoints
   */
  angular.module('calcentral.factories').factory('canvasCourseGradeExportFactory', function($http) {
    var exportOptions = function(canvasCourseId) {
      return $http.get('/api/academics/canvas/egrade_export/options/' + canvasCourseId);
    };

    var prepareGradesCacheJob = function(canvasCourseId) {
      return $http.post('/api/academics/canvas/egrade_export/prepare/' + canvasCourseId);
    };

    var jobStatus = function(canvasCourseId, jobId) {
      return $http.get('/api/academics/canvas/egrade_export/status/' + canvasCourseId + '?jobId=' + jobId);
    };

    return {
      exportOptions: exportOptions,
      prepareGradesCacheJob: prepareGradesCacheJob,
      jobStatus: jobStatus
    };
  });
}(window.angular));
