/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Add User to Course LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseGradeExportController', function(apiService, canvasCourseGradeExportFactory, canvasSharedFactory, $http, $routeParams, $scope, $timeout, $window) {
    apiService.util.setTitle('E-Grade Export');

    $scope.appState = 'initializing';
    $scope.canvasCourseId = $routeParams.canvasCourseId || 'embedded';
    $scope.enableDefaultGradingScheme = false;
    $scope.resolvingCourseState = false;

    /**
     * Sends message to parent window to switch to gradebook
     */
    $scope.goToGradebook = function() {
      var gradebookUrl = $scope.canvasRootUrl + '/courses/' + $scope.canvasCourseId + '/grades';
      if (apiService.util.isInIframe) {
        apiService.util.iframeParentLocation(gradebookUrl);
      } else {
        $window.location.href = gradebookUrl;
      }
    };

    /**
     * Sends message to parent window to go to Course Settings
     */
    $scope.goToCourseSettings = function() {
      var courseDetailsUrl = $scope.canvasRootUrl + '/courses/' + $scope.canvasCourseId + '/settings#tab-details';
      if (apiService.util.isInIframe) {
        apiService.util.iframeParentLocation(courseDetailsUrl);
      } else {
        $window.location.href = courseDetailsUrl;
      }
    };

    /*
     * Updates status of background job in $scope.
     * Halts jobStatusLoader loop if job no longer in progress.
     */
    var statusProcessor = function(data) {
      angular.extend($scope, data);
      $scope.percentCompleteRounded = Math.round($scope.percentComplete * 100);
      if ($scope.jobStatus === 'Processing' || $scope.jobStatus === 'New') {
        jobStatusLoader();
      } else {
        delete $scope.percentCompleteRounded;
        $timeout.cancel(timeoutPromise);
        $scope.switchToSelection();
        downloadGrades();
      }
    };

    /*
     * Performs background job status request every 2000 miliseconds
     * with result processed by statusProcessor.
     */
    var timeoutPromise;
    var jobStatusLoader = function() {
      timeoutPromise = $timeout(function() {
        return canvasCourseGradeExportFactory.jobStatus($scope.canvasCourseId, $scope.backgroundJobId)
          .success(statusProcessor)
          .error(function() {
            $scope.errorStatus = 'error';
            $scope.contactSupport = true;
            $scope.displayError = 'Unable to obtain grade preloading status.';
          });
      }, 2000);
    };

    /*
     * Begins grade preparation and download process
     */
    $scope.preloadGrades = function(type) {
      $scope.selectedType = type;
      $scope.appState = 'loading';
      $scope.jobStatus = 'New';
      apiService.util.iframeScrollToTop();
      canvasCourseGradeExportFactory.prepareGradesCacheJob($scope.canvasCourseId).success(function(data) {
        if (data.jobRequestStatus === 'Success') {
          $scope.backgroundJobId = data.jobId;
          jobStatusLoader();
        } else {
          $scope.appState = 'error';
          $scope.contactSupport = true;
          $scope.errorStatus = 'Grade preloading request failed';
        }
      }).error(function() {
        $scope.appState = 'error';
        $scope.contactSupport = true;
        $scope.errorStatus = 'Grade preloading failed';
      });
    };

    $scope.getExportOptions = function() {
      canvasCourseGradeExportFactory.exportOptions($scope.canvasCourseId).success(function(data) {
        if ($scope.appState !== 'error') {
          loadSectionTerms(data.sectionTerms);
        }
        if ($scope.appState !== 'error') {
          loadOfficialSections(data.officialSections);
        }
        if ($scope.appState !== 'error') {
          validateCourseState(data.gradingStandardEnabled, data.mutedAssignments);
        }
        if ($scope.appState !== 'error') {
          $scope.appState = 'selection';
        }
      }).error(function() {
        $scope.appState = 'error';
        $scope.contactSupport = true;
        $scope.errorStatus = 'Unable to obtain course settings.';
      });
    };

    $scope.notReadyForPreparation = function() {
      if ($scope.noGradingStandardEnabled && $scope.mutedAssignmentsPresent && $scope.enableDefaultGradingScheme && $scope.unmuteAllAssignments) {
        return false;
      }
      if ($scope.noGradingStandardEnabled && !$scope.mutedAssignmentsPresent && $scope.enableDefaultGradingScheme) {
        return false;
      }
      if (!$scope.noGradingStandardEnabled && $scope.mutedAssignmentsPresent && $scope.unmuteAllAssignments) {
        return false;
      }
      return true;
    };

    /*
     * Switches to 'selection' step and scrolls to top of page
     */
    $scope.switchToSelection = function() {
      apiService.util.iframeScrollToTop();
      $scope.appState = 'selection';
    };

    $scope.resolveIssues = function() {
      $scope.resolvingCourseState = true;
      canvasCourseGradeExportFactory.resolveIssues($scope.canvasCourseId, $scope.enableDefaultGradingScheme, $scope.unmuteAllAssignments)
        .success(function(data) {
          if (data.status && data.status === 'Resolved') {
            $scope.resolvingCourseState = false;
            $scope.switchToSelection();
          } else {
            $scope.appState = 'error';
            $scope.contactSupport = true;
            $scope.errorStatus = 'Error resolving course site state for E-Grades Export.';
          }
        }).error(function() {
          $scope.appState = 'error';
          $scope.contactSupport = true;
          if ($scope.enableDefaultGradingScheme) {
            $scope.errorStatus = 'Error enabling grading scheme.';
          }
          if ($scope.unmuteAllAssignments) {
            $scope.errorStatus = 'Error enabling unmuting assignments.';
          }
          if ($scope.enableDefaultGradingScheme && $scope.unmuteAllAssignments) {
            $scope.errorStatus = 'Error enabling grading scheme and unmuting assignments.';
          }
        });
    };

    /*
     * Triggers auto-download of selected CSV download
     */
    var downloadGrades = function() {
      var downloadPath = [
        '/api/academics/canvas/egrade_export/download/',
        $scope.canvasCourseId + '.csv?',
        'ccn=' + $scope.selectedSection.course_cntl_num + '&',
        'term_cd=' + $scope.selectedSection.term_cd + '&',
        'term_yr=' + $scope.selectedSection.term_yr + '&',
        'type=' + $scope.selectedType
      ].join('');
      $window.location.href = downloadPath;
    };

    /**
     * Performs authorization check on user to control interface presentation
     */
    var checkAuthorization = function() {
      canvasSharedFactory.courseUserRoles($scope.canvasCourseId).success(function(data) {
        $scope.canvasRootUrl = data.canvasRootUrl;
        $scope.canvasCourseId = data.courseId;
        $scope.courseUserRoles = data.roles;

        $scope.userAuthorized = userIsAuthorized($scope.courseUserRoles);
        if ($scope.userAuthorized) {
          $scope.getExportOptions();
        } else {
          $scope.appState = 'error';
          $scope.errorStatus = 'You must be a teacher in this bCourses course to export to E-Grades CSV.';
        }
      }).error(function(data) {
        $scope.userAuthorized = false;
        $scope.appState = 'error';
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Authorization Check Failed';
          $scope.contactSupport = true;
        }
      });
    };

    /* Load and initialize application based on section terms provided */
    var loadSectionTerms = function(sectionTerms) {
      if (sectionTerms && sectionTerms.length > 0) {
        $scope.sectionTerms = sectionTerms;

        if ($scope.sectionTerms.length > 1) {
          $scope.appState = 'error';
          $scope.errorStatus = 'This course site contains sections from multiple terms. Only sections from a single term should be present.';
          $scope.contactSupport = true;
        }
      } else {
        $scope.appState = 'error';
        $scope.errorStatus = 'No sections found in this course representing an official campus term.';
        $scope.unexpectedContactSupport = true;
      }
    };

    /* Load and initialize application based on grading standard and muted assignment states for course */
    var validateCourseState = function(gradingStandardEnabled, mutedAssignments) {
      $scope.mutedAssignments = mutedAssignments;
      if (!gradingStandardEnabled) {
        $scope.appState = 'error';
        $scope.noGradingStandardEnabled = true;
      }
      if (mutedAssignments.length > 0) {
        $scope.appState = 'error';
        $scope.mutedAssignmentsPresent = true;
      }
    };

    /* Load and initialize application based on official sections */
    var loadOfficialSections = function(officialSections) {
      if (officialSections && officialSections.length > 0) {
        $scope.officialSections = officialSections;
        $scope.selectedSection = $scope.officialSections[0];
      } else {
        $scope.appState = 'error';
        $scope.errorStatus = 'None of the sections within this course site are associated with UC Berkeley course catalog sections.';
        $scope.contactSupport = true;
      }
    };

    var userIsAuthorized = function(courseUserRoles) {
      return (courseUserRoles.globalAdmin || courseUserRoles.teacher);
    };

    checkAuthorization();
  });
})(window.angular);
