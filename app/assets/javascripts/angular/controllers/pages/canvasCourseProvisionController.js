(function(angular) {
  'use strict';

  /**
   * Canvas course provisioning LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseProvisionController', function (apiService, $http, $scope, $timeout, $window) {

    apiService.util.setTitle('bCourses Course Provision');

    /**
     * Post a message to the parent
     * @param {String|Object} message Message you want to send over.
     */
    var postMessage = function(message) {
      if ($window.parent) {
        $window.parent.postMessage(message, '*');
      }
    };

    var postHeight = function() {
      postMessage({
        height: document.body.scrollHeight
      });
    };

    var statusProcessor = function() {
      if ($scope.status === 'Processing' || $scope.status === 'New') {
        courseSiteJobStatusLoader();
      } else {
        $timeout.cancel(timeout_promise);
      }
    };

    var timeout_promise;
    var courseSiteJobStatusLoader = function() {
      $scope.current_workflow_step = 'monitoring_job';
      timeout_promise = $timeout(function() {
        fetchStatus(statusProcessor);
      }, 2000);
    };

    var clearCourseSiteJob = function() {
      delete $scope.job_id;
      delete $scope.job_request_status;
      delete $scope.status;
      delete $scope.completed_steps;
      delete $scope.percent_complete;
    };

    var courseSiteJobCreated = function(data) {
      angular.extend($scope, data);
      courseSiteJobStatusLoader();
    };

    $scope.createCourseSiteJob = function(selected_courses) {
      var ccns = [];
      angular.forEach(selected_courses, function(course) {
        angular.forEach(course.sections, function(section) {
          if (section.selected) {
            ccns.push(section.ccn);
          }
        });
      });
      if (ccns.length > 0) {
        var new_course = {
          'term_slug': $scope.current_semester,
          'ccns': ccns
        };
        if ($scope.is_admin) {
          if ($scope.admin_mode !== 'by_ccn' && $scope.admin_acting_as) {
            new_course.admin_acting_as = $scope.admin_acting_as;
          } else if ($scope.admin_mode === 'by_ccn' && $scope.admin_by_ccns) {
            new_course.admin_by_ccns = $scope.admin_by_ccns;
            new_course.admin_term_slug = $scope.current_admin_semester;
          }
        }
        $http.post('/api/academics/canvas/course_provision/create', new_course)
          .success(courseSiteJobCreated)
          .error(function() {
            angular.extend($scope, {
              current_workflow_step: 'monitoring_job',
              status: 'Error',
              error: 'Failed to create course provisioning job.'
            });
          });
      }
    };

    var fetchStatus = function(callback) {
      var status_request = {
        url: '/api/academics/canvas/course_provision/status.json',
        method: 'GET',
        params: { 'job_id': $scope.job_id }
      };
      $http(status_request).success(function(data) {
        angular.extend($scope, data);
        $scope.percent_complete_rounded = Math.round($scope.percent_complete * 100);
        callback();
      });
    };

    $scope.fetchFeed = function() {
      clearCourseSiteJob();
      angular.extend($scope, {
        current_workflow_step: 'selecting',
        is_loading: true,
        created_status: false
      });
      var feed_url = '/api/academics/canvas/course_provision';
      var feed_params = {};
      if ($scope.is_admin) {
        if ($scope.admin_mode !== 'by_ccn' && $scope.admin_acting_as) {
          feed_url = '/api/academics/canvas/course_provision_as/' + $scope.admin_acting_as;
        } else if ($scope.admin_mode === 'by_ccn' && $scope.admin_by_ccns) {
          feed_params = {
            'admin_by_ccns[]': $scope.admin_by_ccns,
            'admin_term_slug': $scope.current_admin_semester
          };
        }
      }
      $http({
        url: feed_url,
        method: 'GET',
        params: feed_params
      }).success(function(data) {
        angular.extend($scope, data);
        window.setInterval(postHeight, 250);
        if ($scope.teaching_semesters && $scope.teaching_semesters.length > 0) {
          $scope.switchSemester($scope.teaching_semesters[0]);
        }
        if (!$scope.current_admin_semester && $scope.admin_semesters && $scope.admin_semesters.length > 0) {
          $scope.switchAdminSemester($scope.admin_semesters[0]);
        }
        if ($scope.admin_mode === 'by_ccn' && $scope.admin_by_ccns) {
          selectAllSections();
        }
      });
    };

    var selectAllSections = function() {
      var new_selected_courses = [];
      angular.forEach($scope.selected_courses, function(course) {
        angular.forEach(course.sections, function(section) {
          section.selected = true;
        });
        new_selected_courses.push(course);
      });
      $scope.selected_courses = new_selected_courses;
    };

    $scope.switchAdminSemester = function(semester) {
      angular.extend($scope, {
        current_admin_semester: semester.slug
      });
    };

    $scope.switchSemester = function(semester) {
      angular.extend($scope, {
        current_semester: semester.slug,
        selected_courses: semester.classes
      });
    };

    $scope.toggleAdminMode = function() {
      var admin_mode;
      if ($scope.admin_mode === 'by_ccn') {
        admin_mode = 'act_as';
      } else {
        admin_mode = 'by_ccn';
      }
      clearCourseSiteJob();
      angular.extend($scope, {
        current_workflow_step: 'selecting',
        admin_mode: admin_mode,
        teaching_semesters: []
      });
    };

    $scope.fetchFeed();
  });

})(window.angular);
