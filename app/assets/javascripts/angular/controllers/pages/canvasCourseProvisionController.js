/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas course provisioning LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseProvisionController', function(apiService, canvasCourseProvisionFactory, $scope, $timeout) {
    apiService.util.setTitle('bCourses Course Provision');

    var statusProcessor = function() {
      if ($scope.status === 'Processing' || $scope.status === 'New') {
        courseSiteJobStatusLoader();
      } else {
        delete $scope.percentCompleteRounded;
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
      canvasCourseProvisionFactory.courseProvisionJobStatus($scope.job_id).success(function(data) {
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
      angular.forEach($scope.currentCourses, function(course) {
        angular.forEach(course.sections, function(section) {
          section.selected = true;
        });
        newSelectedCourses.push(course);
      });
      $scope.currentCourses = newSelectedCourses;
    };

    var selectedCcns = function() {
      var ccns = [];
      angular.forEach($scope.selectedSections(), function(section) {
        ccns.push(section.ccn);
      });
      return ccns;
    };

    $scope.errorEmail = function() {
      window.top.location = 'mailto:bcourseshelp@berkeley.edu?subject=bCourses+Course+Site+Creation+Failure';
    };

    $scope.selectedSections = function() {
      var selectedSections = [];
      angular.forEach($scope.currentCourses, function(course) {
        angular.forEach(course.sections, function(section) {
          if (section.selected) {
            section.courseTitle = course.title;
            section.courseCatalog = course.course_catalog;
            selectedSections.push(section);
          }
        });
      });
      return selectedSections;
    };

    $scope.toggleCheckboxes = function(selectedCourse) {
      selectedCourse.allSelected = !selectedCourse.allSelected;
      selectedCourse.selectToggleText = selectedCourse.allSelected ? 'None' : 'All';
      angular.forEach(selectedCourse.sections, function(section) {
        section.selected = selectedCourse.allSelected;
      });
    };

    $scope.showSelecting = function() {
      $scope.currentWorkflowStep = 'selecting';
    };

    $scope.showConfirmation = function() {
      $scope.currentWorkflowStep = 'confirmation';
      var selectedSections = $scope.selectedSections();
      $scope.siteName = selectedSections[0].courseTitle;
      $scope.siteAbbreviation = selectedSections[0].courseCode + ' - ' + selectedSections[0].section_label;
      apiService.util.iframeScrollToTop();
    };

    $scope.createCourseSiteJob = function() {
      var ccns = selectedCcns();
      if (ccns.length > 0) {
        var newCourse = {
          'siteName': $scope.siteName,
          'siteAbbreviation': $scope.siteAbbreviation,
          'termSlug': $scope.currentSemester,
          'ccns': ccns
        };
        if ($scope.is_admin) {
          if ($scope.adminMode !== 'by_ccn' && $scope.admin_acting_as) {
            newCourse.admin_acting_as = $scope.admin_acting_as;
          } else if ($scope.adminMode === 'by_ccn' && $scope.admin_by_ccns) {
            newCourse.admin_by_ccns = $scope.admin_by_ccns.match(/\w+/g);
            newCourse.admin_term_slug = $scope.currentAdminSemester;
          }
        }

        canvasCourseProvisionFactory.courseCreate(newCourse)
          .success(courseSiteJobCreated)
          .error(function() {
            angular.extend($scope, {
              percentCompleteRounded: 0,
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
      var feedRequestOptions = {
        isAdmin: $scope.is_admin,
        adminMode: $scope.adminMode,
        adminActingAs: $scope.admin_acting_as,
        adminByCcns: $scope.admin_by_ccns,
        currentAdminSemester: $scope.currentAdminSemester
      };
      canvasCourseProvisionFactory.getSections(feedRequestOptions).then(function(sectionsFeed){
        if (sectionsFeed.status !== 200) {
          $scope.isLoading = false;
          $scope.feedFetchError = true;
        } else {
          if (sectionsFeed.data) {
            angular.extend($scope, sectionsFeed.data);
            fillCourseSites($scope.teachingSemesters);
            apiService.util.iframeUpdateHeight();
            if ($scope.teachingSemesters && $scope.teachingSemesters.length > 0) {
              $scope.switchSemester($scope.teachingSemesters[0]);
            }
            if (!$scope.currentAdminSemester && $scope.admin_semesters && $scope.admin_semesters.length > 0) {
              $scope.switchAdminSemester($scope.admin_semesters[0]);
            }
            if ($scope.adminMode === 'by_ccn' && $scope.admin_by_ccns) {
              selectAllSections();
            }
            $scope.isCourseCreator = $scope.is_admin || $scope.classCount > 0;
            $scope.feedFetched = true;
          }
        }
      });
    };

    $scope.switchAdminSemester = function(semester) {
      angular.extend($scope, {
        currentAdminSemester: semester.slug
      });
    };

    $scope.switchSemester = function(semester) {
      angular.extend($scope, {
        currentSemester: semester.slug,
        currentCourses: semester.classes
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
