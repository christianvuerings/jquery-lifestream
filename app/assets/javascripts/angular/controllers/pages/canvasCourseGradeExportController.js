/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Add User to Course LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseGradeExportController', function(apiService, canvasCourseGradeExportFactory, $http, $scope) {
    apiService.util.setTitle('eGrade Export');

    $scope.appState = 'initializing';

    /**
     * Sends message to parent window to switch to gradebook
     */
    $scope.goToGradebook = function() {
      var gradebookUrl = $scope.parentHostUrl + '/courses/' + $scope.canvasCourseId + '/grades';
      apiService.util.iframeParentLocation(gradebookUrl);
    };

    /**
     * Sends message to parent window to go to Course Details
     */
    $scope.goToCourseDetails = function() {
      var courseDetailsUrl = $scope.parentHostUrl + '/courses/' + $scope.canvasCourseId + '/settings#tab-details';
      apiService.util.iframeParentLocation(courseDetailsUrl);
    };

    /**
     * Performs authorization check on user to control interface presentation
     */
    var checkAuthorization = function() {
      canvasCourseGradeExportFactory.checkAuthorization().success(function(data) {
        $scope.courseUserRoles = data.roles;
        $scope.canvasCourseId = data.courseId;

        // get iframe parent hostname
        var parser = document.createElement('a');
        parser.href = document.referrer;
        $scope.parentHostUrl = parser.protocol + '//' + parser.host;

        $scope.userAuthorized = userIsAuthorized($scope.courseUserRoles);
        if ($scope.userAuthorized) {
          getExportOptions();
        } else {
          $scope.appState = 'error';
          $scope.errorStatus = 'You must be a teacher in this bCourses course to export to eGrades CSV.';
        }
      }).error(function(data) {
        $scope.userAuthorized = false;
        $scope.appState = 'error';
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Authorization Check Failed';
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

    /* Load and initialize application based on grade types present */
    var loadGradeTypes = function(gradeTypesPresent) {
      if (!gradeTypesPresent.number_grades_present) {
        $scope.appState = 'error';
        $scope.noNumberGrades = true;
      }
      if (!gradeTypesPresent.letter_grades_present) {
        $scope.appState = 'error';
        if ($scope.noNumberGrades !== true) {
          $scope.noLetterGrades = true;
        }
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
      canvasCourseGradeExportFactory.exportOptions().success(function(data) {
        if ($scope.appState !== 'error') {
          loadSectionTerms(data.section_terms);
        }
        if ($scope.appState !== 'error') {
          loadGradeTypes(data.grade_types_present);
        }
        if ($scope.appState !== 'error') {
          loadOfficialSections(data.official_sections);
        }
        if ($scope.appState !== 'error') {
          $scope.appState = 'ready';
        }
      }).error(function(data) {
        $scope.showError = true;
        $scope.errorStatus = data;
      });
    };

    var userIsAuthorized = function(courseUserRoles) {
      return (courseUserRoles.globalAdmin || courseUserRoles.teacher);
    };

    apiService.util.iframeUpdateHeight();
    checkAuthorization();
  });
})(window.angular);
