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
     * Initializes selected and course site association states in semesters feed
     */
    var fillCourseSites = function(semestersFeed) {
      angular.forEach(semestersFeed, function(semester) {
        angular.forEach(semester.classes, function(course) {
          course.collapsed = true;
          course.allSelected = false;
          course.selectToggleText = 'All';
          var hasSites = false;
          var ccnToSites = {};
          angular.forEach(course.class_sites, function(site) {
            if (site.emitter === 'bCourses') {
              angular.forEach(site.sections, function(siteSection) {
                hasSites = true;
                if (!ccnToSites[siteSection.ccn]) {
                  ccnToSites[siteSection.ccn] = [];
                }
                ccnToSites[siteSection.ccn].push(site);
              });
            }
          });
          if (hasSites) {
            course.hasSites = hasSites;
            angular.forEach(course.sections, function(section) {
              var ccn = section.ccn;
              if (ccnToSites[ccn]) {
                section.sites = ccnToSites[ccn];
              }
            });
          }
        });
      });
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

    /*
     * Adds class count to response data
     */
    var parseSectionsFeed = function(feedResponse) {
      if (!feedResponse.data && !feedResponse.data.teachingSemesters) {
        return feedResponse;
      }
      feedResponse.data.usersClassCount = classCount(feedResponse.data.teachingSemesters);
      fillCourseSites(feedResponse.data.teachingSemesters);
      return feedResponse;
    };

    /*
     * Sends request to add and/or delete sections from existing course site
     */
    var updateSections = function(canvasCourseId, addCcns, deleteCcns) {
      return $http.post('/api/academics/canvas/course_provision/edit_sections', {
        canvas_course_id: canvasCourseId,
        ccns_to_remove: deleteCcns,
        ccns_to_add: addCcns
      });
    };

    return {
      courseCreate: courseCreate,
      courseProvisionJobStatus: courseProvisionJobStatus,
      getSections: getSections,
      updateSections: updateSections
    };
  });
}(window.angular));
