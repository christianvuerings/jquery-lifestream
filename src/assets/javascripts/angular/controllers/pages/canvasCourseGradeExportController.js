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

    /**
     * Sends message to parent window to switch to gradebook
     */
    $scope.goToGradebook = function() {
      var gradebookUrl = $scope.canvasRootUrl + '/courses/' + $scope.canvasCourseId + '/grades';
      apiService.util.iframeParentLocation(gradebookUrl);
    };

    /**
     * Sends message to parent window to go to Course Settings
     */
    $scope.goToCourseSettings = function() {
      var courseDetailsUrl = $scope.canvasRootUrl + '/courses/' + $scope.canvasCourseId + '/settings#tab-details';
      if (!!window.parent.frames.length) {
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
        $scope.appState = 'ready';
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
     * Begins grade preloading process
     */
    $scope.preloadGrades = function() {
      $scope.appState = 'loading';
      $scope.jobStatus = 'New';
      canvasCourseGradeExportFactory.prepareGradesCacheJob($scope.canvasCourseId, $scope.enableDefaultGradingScheme).success(function(data) {
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
          getExportOptions();
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

    /* Load and initialize application based on grading standard state for course */
    var handleGradingStandardState = function(gradingStandardEnabled) {
      if (!gradingStandardEnabled) {
        $scope.appState = 'error';
        $scope.noGradingStandardEnabled = true;
      }
    };

    /* Load and initialize application based on muted Assignments */
    var handleMutedAssignments = function(mutedAssignments) {
      $scope.mutedAssignments = mutedAssignments;
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

    var getExportOptions = function() {
      canvasCourseGradeExportFactory.exportOptions($scope.canvasCourseId).success(function(data) {
        if ($scope.appState !== 'error') {
          loadSectionTerms(data.sectionTerms);
        }
        if ($scope.appState !== 'error') {
          loadOfficialSections(data.officialSections);
        }
        if ($scope.appState !== 'error') {
          handleGradingStandardState(data.gradingStandardEnabled);
          handleMutedAssignments(data.mutedAssignments);
        }
        if ($scope.appState !== 'error') {
          $scope.preloadGrades();
        }
      }).error(function() {
        $scope.appState = 'error';
        $scope.contactSupport = true;
        $scope.errorStatus = 'Unable to obtain course settings.';
      });
    };

    var userIsAuthorized = function(courseUserRoles) {
      return (courseUserRoles.globalAdmin || courseUserRoles.teacher);
    };

    apiService.util.iframeUpdateHeight();
    checkAuthorization();
  });
})(window.angular);
