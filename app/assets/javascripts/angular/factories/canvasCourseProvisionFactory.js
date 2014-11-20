/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Course Provision Factory - API Interface for 'Create a Course Site' and 'Official Sections' LTI Tools
   */
  angular.module('calcentral.factories').factory('canvasCourseProvisionFactory', function($http) {
    var courseProvisionJobStatus = function(jobId) {
      return $http.get('/api/academics/canvas/course_provision/status.json', {
        params: {
          job_id: jobId
        }
      });
    };

    var courseCreate = function(newCourse) {
      return $http.post('/api/academics/canvas/course_provision/create', newCourse);
    };

    var getFeed = function(isAdmin, adminMode, adminActingAs, adminByCcns, currentAdminSemester) {
      var feedUrl = '/api/academics/canvas/course_provision';
      var feedParams = {};
      if (isAdmin) {
        if (adminMode !== 'by_ccn' && adminActingAs) {
          feedUrl = '/api/academics/canvas/course_provision_as/' + adminActingAs;
        } else if (adminMode === 'by_ccn' && adminByCcns) {
          feedParams = {
            'admin_by_ccns[]': adminByCcns.match(/\w+/g),
            'admin_term_slug': currentAdminSemester
          };
        }
      }
      return $http.get(feedUrl, {
        params: feedParams
      });
    };

    return {
      getFeed: getFeed,
      courseCreate: courseCreate,
      courseProvisionJobStatus: courseProvisionJobStatus
    };
  });
}(window.angular));
