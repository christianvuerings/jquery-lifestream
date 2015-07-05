/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Academics controller
   */
  angular.module('calcentral.controllers').controller('AcademicsController', function(academicsFactory, academicsService, apiService, badgesFactory, $routeParams, $scope) {
    apiService.util.setTitle('My Academics');

    var checkPageExists = function(page) {
      if (!page) {
        apiService.util.redirect('404');
        return false;
      } else {
        return true;
      }
    };

    var updatePrevNextSemester = function(semestersLists, selectedSemester) {
      var nextSemester = {};
      var nextSemesterCompare = false;
      var previousSemester = {};
      var previousSemesterCompare = false;
      var selectedSemesterCompare = selectedSemester.termYear + selectedSemester.termCode;
      for (var i = 0; i < semestersLists.length; i++) {
        var semesterList = semestersLists[i];
        if (!semesterList) {
          continue;
        }
        var isStudentSemesterList = (i === 0);
        for (var j = 0; j < semesterList.length; j++) {
          var semester = semesterList[j];
          if (isStudentSemesterList && !semester.hasEnrollmentData) {
            continue;
          }
          var cmp = semester.termYear + semester.termCode;
          if ((cmp < selectedSemesterCompare) && (!previousSemesterCompare || (cmp > previousSemesterCompare))) {
            previousSemesterCompare = cmp;
            previousSemester.slug = semester.slug;
          } else if ((cmp > selectedSemesterCompare) && (!nextSemesterCompare || (cmp < nextSemesterCompare))) {
            nextSemesterCompare = cmp;
            nextSemester.slug = semester.slug;
          }
        }
      }
      $scope.nextSemester = nextSemester;
      $scope.previousSemester = previousSemester;
      $scope.previousNextSemesterShow = (nextSemesterCompare || previousSemesterCompare);
    };

    var fillSemesterSpecificPage = function(semesterSlug, data) {
      var isOnlyInstructor = !!$routeParams.teachingSemesterSlug;
      var selectedStudentSemester = academicsService.findSemester(data.semesters, semesterSlug, selectedStudentSemester);
      var selectedTeachingSemester = academicsService.findSemester(data.teachingSemesters, semesterSlug, selectedTeachingSemester);
      var selectedSemester = (selectedStudentSemester || selectedTeachingSemester);
      if (!checkPageExists(selectedSemester)) {
        return;
      }
      var selectedTelebears = academicsService.findSemester(data.telebears, semesterSlug, selectedTelebears);
      updatePrevNextSemester([data.semesters, data.teachingSemesters], selectedSemester);

      $scope.selectedSemester = selectedSemester;
      if (selectedStudentSemester && !$routeParams.classSlug) {
        $scope.selectedCourses = selectedStudentSemester.classes;
        if (!isOnlyInstructor) {
          $scope.allCourses = academicsService.getAllClasses(data.semesters);
          $scope.previousCourses = academicsService.getPreviousClasses(data.semesters);
          $scope.enrolledCourses = academicsService.getClassesSections(selectedStudentSemester.classes, false);
          $scope.waitlistedCourses = academicsService.getClassesSections(selectedStudentSemester.classes, true);
        }
      }
      $scope.selectedStudentSemester = selectedStudentSemester;
      $scope.selectedTeachingSemester = selectedTeachingSemester;
      if (selectedTelebears) {
        $scope.telebearsSemesters = [selectedTelebears];
      }

      // Get selected course from URL params and extract data from selected semester schedule
      if ($routeParams.classSlug) {
        $scope.isInstructorOrGsi = isOnlyInstructor;
        var classSemester = selectedStudentSemester;
        if (isOnlyInstructor) {
          classSemester = selectedTeachingSemester;
        }
        for (var i = 0; i < classSemester.classes.length; i++) {
          var course = classSemester.classes[i];
          if (course.slug === $routeParams.classSlug) {
            if ($routeParams.sectionSlug) {
              $scope.selectedSection = academicsService.filterBySectionSlug(course, $routeParams.sectionSlug);
            }
            academicsService.normalizeGradingData(course);
            $scope.selectedCourse = (course.sections.length) ? course : null;
            if (isOnlyInstructor) {
              $scope.campusCourseId = course.listings[0].course_id;
            }
            break;
          }
        }
        if (!checkPageExists($scope.selectedCourse)) {
          return;
        }
        if ($routeParams.sectionSlug && !checkPageExists($scope.selectedSection)) {
          return;
        }
        $scope.selectedCourseCountInstructors = academicsService.countSectionItem($scope.selectedCourse, 'instructors');
        $scope.selectedCourseCountSchedules = academicsService.countSectionItem($scope.selectedCourse, 'schedules');
        $scope.selectedCourseCountScheduledSections = academicsService.countSectionItem($scope.selectedCourse);
        $scope.selectedCourseLongInstructorsList = ($scope.selectedCourseCountScheduledSections > 5) || ($scope.selectedCourseCountInstructors > 10);
      }
    };

    var parseAcademics = function(data) {
      angular.extend($scope, data);

      $scope.semesters = data.semesters;

      if (data.semesters) {
        $scope.pastSemestersCount = academicsService.pastSemestersCount(data.semesters);
        $scope.pastSemestersLimit = data.semesters.length - $scope.pastSemestersCount + 1;
        if (data.additionalCredits) {
          $scope.pastSemestersCount++;
        }
      }

      $scope.isLSStudent = academicsService.isLSStudent($scope.collegeAndLevel);
      $scope.isUndergraduate = ($scope.collegeAndLevel && $scope.collegeAndLevel.standing === 'Undergraduate');

      $scope.isAcademicInfoAvailable = !!(($scope.semesters && $scope.semesters.length) ||
                                          ($scope.requirements && $scope.requirements.length) ||
                                          ($scope.studentInfo && $scope.studentInfo.regStatus && $scope.studentInfo.regStatus.code !== null));

      $scope.isProfileCurrent = !$scope.transitionTerm || $scope.transitionTerm.isProfileCurrent;
      $scope.showProfileMessage = (!$scope.isProfileCurrent || !$scope.collegeAndLevel || !$scope.collegeAndLevel.standing);

      $scope.hasTeachingClasses = academicsService.hasTeachingClasses(data.teachingSemesters);
      if (data.teachingSemesters) {
        $scope.pastSemestersTeachingCount = academicsService.pastSemestersCount(data.teachingSemesters);
        $scope.pastSemestersTeachingLimit = data.teachingSemesters.length - $scope.pastSemestersTeachingCount + 1;
      }

      // Get selected semester from URL params and extract data from semesters array
      var semesterSlug = ($routeParams.semesterSlug || $routeParams.teachingSemesterSlug);
      if (semesterSlug) {
        fillSemesterSpecificPage(semesterSlug, data);
      } else {
        $scope.telebearsSemesters = data.telebears;
        if ($scope.hasTeachingClasses && (!data.semesters || (data.semesters.length === 0))) {
          // Show the current semester, or the most recent semester, since otherwise the instructor
          // landing page will be grimly bare.
          $scope.selectedTeachingSemester = academicsService.chooseDefaultSemester(data.teachingSemesters);
          $scope.widgetSemesterName = $scope.selectedTeachingSemester.name;
        }
      }
      $scope.gpaUnits.cumulativeGpaFloat = $scope.gpaUnits.cumulativeGpa; // cumulativeGpa is passed as a string to maintain two significant digits
      $scope.gpaUnits.cumulativeGpa = parseFloat($scope.gpaUnits.cumulativeGpa); // converted to Float to be processed regularly
    };

    $scope.currentSelection = 'Class Info';
    $scope.selectOptions = ['Class Info', 'Class Roster'];

    $scope.switchSelectedOption = function(selectedOption) {
      $scope.currentSelection = selectedOption;
    };

    // Wait until user profile is fully loaded before hitting academics data
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        $scope.canViewAcademics = $scope.api.user.profile.hasAcademicsTab;
        academicsFactory.getAcademics().success(parseAcademics);
        badgesFactory.getBadges().success(function(data) {
          $scope.studentInfo = data.studentInfo;
          if ($scope.studentInfo.isLawStudent) {
            $scope.transcriptLink = 'http://www.law.berkeley.edu/php-programs/registrar/forms/transcriptrequestform.php';
          } else {
            $scope.transcriptLink = 'https://telebears.berkeley.edu/tranreq/';
          }
        });
      }
    });
  });
})(window.angular);
