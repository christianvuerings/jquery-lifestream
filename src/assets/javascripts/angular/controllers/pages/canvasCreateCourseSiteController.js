/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas course provisioning LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCreateCourseSiteController', function(apiService, canvasCourseProvisionFactory, canvasSiteCreationService, $route, $scope, $timeout) {
    apiService.util.setTitle('Create a Course Site');

    // initialize maintenance notice settings
    $scope.courseActionVerb = 'site is created';
    $scope.maintenanceCollapsed = true;
    $scope.showMaintenanceNotice = true;

    $scope.accessDeniedError = 'This feature is currently only available to instructors with course sections scheduled in the current or upcoming terms.';
    $scope.linkToSiteOverview = canvasSiteCreationService.linkToSiteOverview($route.current.isEmbedded);

    /*
     * Updates status of background job in $scope.
     * Halts jobStatusLoader loop if job no longer in progress.
     */
    var statusProcessor = function(data) {
      angular.extend($scope, data);
      $scope.percentCompleteRounded = Math.round($scope.percent_complete * 100);
      if ($scope.jobStatus === 'Processing' || $scope.jobStatus === 'New') {
        jobStatusLoader();
      } else {
        delete $scope.percentCompleteRounded;
        $timeout.cancel(timeoutPromise);
      }
    };

    /*
     * Performs background job status request every 2000 miliseconds
     * with result processed by statusProcessor.
     */
    var timeoutPromise;
    var jobStatusLoader = function() {
      timeoutPromise = $timeout(function() {
        return canvasCourseProvisionFactory.courseProvisionJobStatus($scope.job_id)
          .success(statusProcessor).error(function() {
            $scope.displayError = 'failure';
          });
      }, 2000);
    };

    /*
     * Saves background job ID to scope and begins background job monitoring loop
     */
    var courseSiteJobCreated = function(data) {
      angular.extend($scope, data);
      $scope.currentWorkflowStep = 'monitoring_job';
      jobStatusLoader();
    };

    var setErrorText = function() {
      $scope.errorConfig = {
        header: 'Course Site Creation Failed: We could not create your site',
        supportAction: 'create your course site manually',
        supportInfo: [
          'The title of the course site you were trying to create',
          'The rosters you would like to add (e.g. BIOLOGY 1A LEC 001)'
        ]
      };
    };

    var clearCourseSiteJob = function() {
      delete $scope.job_id;
      delete $scope.jobStatus;
      delete $scope.completed_steps;
      delete $scope.percent_complete;
      $scope.showMaintenanceNotice = true;
    };

    var selectAllSections = function() {
      var newSelectedCourses = [];
      angular.forEach($scope.coursesList, function(course) {
        angular.forEach(course.sections, function(section) {
          section.selected = true;
        });
        newSelectedCourses.push(course);
      });
      $scope.coursesList = newSelectedCourses;
      $scope.updateSelected();
    };

    var selectedCcns = function() {
      $scope.updateSelected();
      var ccns = $scope.selectedSectionsList.map(function(s) {
        return s.ccn;
      });
      return ccns;
    };

    $scope.errorEmail = function() {
      window.top.location = 'mailto:bcourseshelp@berkeley.edu?subject=bCourses+Course+Site+Creation+Failure';
    };

    $scope.showSelecting = function() {
      $scope.currentWorkflowStep = 'selecting';
    };

    $scope.showConfirmation = function() {
      $scope.updateSelected();
      $scope.currentWorkflowStep = 'confirmation';
      $scope.siteName = $scope.selectedSectionsList[0].courseTitle;
      $scope.siteAbbreviation = $scope.selectedSectionsList[0].courseCode + ' - ' + $scope.selectedSectionsList[0].section_label;
      apiService.util.iframeScrollToTop();
    };

    $scope.createCourseSiteJob = function() {
      if ($scope.createCourseSiteForm.$invalid) {
        return;
      }
      $scope.currentWorkflowStep = 'monitoring_job';
      $scope.showMaintenanceNotice = false;
      setErrorText();
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
              jobStatus: 'courseCreationError',
              error: 'Failed to create course provisioning job.'
            });
          });
      }
    };

    $scope.fetchFeed = function() {
      clearCourseSiteJob();
      angular.extend($scope, {
        isLoading: true,
        currentWorkflowStep: 'selecting',
        selectedSectionsList: []
      });
      var feedRequestOptions = {
        isAdmin: $scope.is_admin,
        adminMode: $scope.adminMode,
        adminActingAs: $scope.admin_acting_as,
        adminByCcns: $scope.admin_by_ccns,
        currentAdminSemester: $scope.currentAdminSemester
      };
      canvasCourseProvisionFactory.getSections(feedRequestOptions).then(function(sectionsFeed) {
        $scope.feedFetched = true;
        if (sectionsFeed.status !== 200) {
          $scope.isLoading = false;
          $scope.displayError = 'failure';
        } else {
          if (sectionsFeed.data) {
            angular.extend($scope, sectionsFeed.data);
            if ($scope.teachingSemesters && $scope.teachingSemesters.length > 0) {
              $scope.switchSemester($scope.teachingSemesters[0]);
            }
            if (!$scope.currentAdminSemester && $scope.admin_semesters && $scope.admin_semesters.length > 0) {
              $scope.switchAdminSemester($scope.admin_semesters[0]);
            }
            if ($scope.adminMode === 'by_ccn' && $scope.admin_by_ccns) {
              selectAllSections();
            }
            if (!($scope.is_admin || $scope.usersClassCount > 0)) {
              $scope.displayError = 'unauthorized';
            }
          }
        }
      });
    };

    /*
     * Selects all sections for a course and updates all detected as selected
     */
    $scope.toggleCourseSectionsWithUpdate = function(course) {
      $scope.toggleCheckboxes(course);
      $scope.updateSelected();
    };

    $scope.switchAdminSemester = function(semester) {
      angular.extend($scope, {
        currentAdminSemester: semester.slug,
        selectedSectionsList: []
      });
      $scope.updateSelected();
    };

    $scope.switchSemester = function(semester) {
      angular.extend($scope, {
        currentSemester: semester.slug,
        coursesList: semester.classes,
        selectedSectionsList: []
      });
      $scope.updateSelected();
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

    $scope.updateSelected = function() {
      $scope.selectedSectionsList = $scope.selectedSections($scope.coursesList);
    };

    $scope.selectedSections = canvasSiteCreationService.selectedSections;
    $scope.toggleCheckboxes = canvasSiteCreationService.toggleCheckboxes;

    /*
     * Used with bc-official-sections-table directive to ensure every section is displayed
     */
    $scope.rowDisplayLogic = function() {
      return true;
    };

    // Wait until user profile is fully loaded before fetching section feed
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        $scope.fetchFeed();
      }
    });
  });
})(window.angular);
