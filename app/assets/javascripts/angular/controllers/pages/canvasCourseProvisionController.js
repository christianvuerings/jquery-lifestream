(function(angular) {
  'use strict';

  /**
   * Canvas course provisioning LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseProvisionController', function(apiService, $http, $scope, $timeout, $window) {

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
        $timeout.cancel(timeoutPromise);
      }
    };

    var timeoutPromise;
    var courseSiteJobStatusLoader = function() {
      $scope.currentWorkflowStep = 'monitoring_job';
      timeoutPromise = $timeout(function() {
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

    var fetchStatus = function(callback) {
      var statusRequest = {
        url: '/api/academics/canvas/course_provision/status.json',
        method: 'GET',
        params: {
          job_id: $scope.job_id
        }
      };
      $http(statusRequest).success(function(data) {
        angular.extend($scope, data);
        $scope.percentCompleteRounded = Math.round($scope.percent_complete * 100);
        callback();
      });
    };

    var fillCourseSites = function(semestersFeed) {
      angular.forEach(semestersFeed, function(semester) {
        angular.forEach(semester.classes, function(course) {
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

    var selectAllSections = function() {
      var newSelectedCourses = [];
      angular.forEach($scope.selectedCourses, function(course) {
        angular.forEach(course.sections, function(section) {
          section.selected = true;
        });
        newSelectedCourses.push(course);
      });
      $scope.selectedCourses = newSelectedCourses;
    };

    $scope.toggleCheckboxes = function(selectedCourse) {
      selectedCourse.allSelected = !selectedCourse.allSelected;
      selectedCourse.selectToggleText = selectedCourse.allSelected ? 'None' : 'All';
      angular.forEach(selectedCourse.sections, function(section) {
        section.selected = selectedCourse.allSelected;
      });
    };

    $scope.createCourseSiteJob = function(selectedCourses) {
      var ccns = [];
      angular.forEach(selectedCourses, function(course) {
        angular.forEach(course.sections, function(section) {
          if (section.selected) {
            ccns.push(section.ccn);
          }
        });
      });
      if (ccns.length > 0) {
        var newCourse = {
          'term_slug': $scope.current_semester,
          'ccns': ccns
        };
        if ($scope.is_admin) {
          if ($scope.adminMode !== 'by_ccn' && $scope.admin_acting_as) {
            newCourse.admin_acting_as = $scope.admin_acting_as;
          } else if ($scope.adminMode === 'by_ccn' && $scope.admin_by_ccns) {
            newCourse.admin_by_ccns = $scope.admin_by_ccns;
            newCourse.admin_term_slug = $scope.currentAdminSemester;
          }
        }
        $http.post('/api/academics/canvas/course_provision/create', newCourse)
          .success(courseSiteJobCreated)
          .error(function() {
            angular.extend($scope, {
              currentWorkflowStep: 'monitoring_job',
              status: 'Error',
              error: 'Failed to create course provisioning job.'
            });
          });
      }
    };

    $scope.fetchFeed = function() {
      clearCourseSiteJob();
      angular.extend($scope, {
        currentWorkflowStep: 'selecting',
        isLoading: true
      });
      var feedUrl = '/api/academics/canvas/course_provision';
      var feedParams = {};
      if ($scope.is_admin) {
        if ($scope.adminMode !== 'by_ccn' && $scope.admin_acting_as) {
          feedUrl = '/api/academics/canvas/course_provision_as/' + $scope.admin_acting_as;
        } else if ($scope.adminMode === 'by_ccn' && $scope.admin_by_ccns) {
          feedParams = {
            'admin_by_ccns[]': $scope.admin_by_ccns,
            'admin_term_slug': $scope.currentAdminSemester
          };
        }
      }
      $http({
        url: feedUrl,
        method: 'GET',
        params: feedParams
      }).success(function(data) {
        angular.extend($scope, data);
        fillCourseSites($scope.teachingSemesters);
        window.setInterval(postHeight, 250);
        if ($scope.teachingSemesters && $scope.teachingSemesters.length > 0) {
          $scope.switchSemester($scope.teachingSemesters[0]);
        }
        if (!$scope.currentAdminSemester && $scope.admin_semesters && $scope.admin_semesters.length > 0) {
          $scope.switchAdminSemester($scope.admin_semesters[0]);
        }
        if ($scope.adminMode === 'by_ccn' && $scope.admin_by_ccns) {
          selectAllSections();
        }
        $scope.isCourseCreator = $scope.is_admin || apiService.user.profile.roles.faculty;
        $scope.feedFetched = true;
      });
    };

    $scope.switchAdminSemester = function(semester) {
      angular.extend($scope, {
        currentAdminSemester: semester.slug
      });
    };

    $scope.switchSemester = function(semester) {
      angular.extend($scope, {
        current_semester: semester.slug,
        selectedCourses: semester.classes
      });
    };

    $scope.toggleAdminMode = function() {
      var adminMode;
      if ($scope.adminMode === 'by_ccn') {
        adminMode = 'act_as';
      } else {
        adminMode = 'by_ccn';
      }
      clearCourseSiteJob();
      angular.extend($scope, {
        currentWorkflowStep: 'selecting',
        adminMode: adminMode,
        teachingSemesters: []
      });
    };

    // Wait until user profile is fully loaded before fetching section feed
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        $scope.fetchFeed();
      }
    });

  });

})(window.angular);
