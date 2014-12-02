/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Course Provision Factory - API Interface for 'Create a Course Site' and 'Official Sections' LTI Tools
   */
  angular.module('calcentral.factories').factory('canvasCourseProvisionFactory', function($http) {

    var classCount = function(teachingSemesters) {
      var count = 0;
      if (teachingSemesters && teachingSemesters.length > 0) {
        angular.forEach(teachingSemesters, function(semester) {
          count += semester.classes.length;
        });
      }
      return count;
    };

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

    /*
     * Used as callback for HTTP error responses
     */
    var errorResponseHandler = function(errorResponse) {
      return errorResponse;
    };

    /*
     * Adds class count to response data
     */
    var parseSectionsFeed = function(feedResponse) {
      if (!feedResponse.data && !feedResponse.data.teachingSemesters) {
        return feedResponse;
      }
      feedResponse.data.classCount = classCount(feedResponse.data.teachingSemesters);
      return feedResponse;
    };

    var getSections = function(feedRequestOptions) {
      var feedUrl = '/api/academics/canvas/course_provision';
      var feedParams = {};
      if (feedRequestOptions.isAdmin) {
        if (feedRequestOptions.adminMode !== 'by_ccn' && feedRequestOptions.adminActingAs) {
          feedUrl = '/api/academics/canvas/course_provision_as/' + feedRequestOptions.adminActingAs;
        } else if (feedRequestOptions.adminMode === 'by_ccn' && feedRequestOptions.adminByCcns) {
          feedParams = {
            'admin_by_ccns[]': feedRequestOptions.adminByCcns.match(/\w+/g),
            'admin_term_slug': feedRequestOptions.currentAdminSemester
          };
        }
      }
      return $http.get(feedUrl, {
        params: feedParams
      })
      .then(function(response) {
        return parseSectionsFeed(response);
      }).catch(errorResponseHandler);
    };

    return {
      getSections: getSections,
      courseCreate: courseCreate,
      courseProvisionJobStatus: courseProvisionJobStatus
    };
  });
}(window.angular));
