/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Academics controller
   */
  angular.module('calcentral.controllers').controller('AcademicsController', function(academicsFactory, apiService, badgesFactory, $routeParams, $scope) {
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
      angular.forEach(semestersLists, function(semesterList) {
        angular.forEach(semesterList, function(semester) {
          var cmp = semester.termYear + semester.termCode;
          if ((cmp < selectedSemesterCompare) && (!previousSemesterCompare || (cmp > previousSemesterCompare))) {
            previousSemesterCompare = cmp;
            previousSemester.slug = semester.slug;
          } else if ((cmp > selectedSemesterCompare) && (!nextSemesterCompare || (cmp < nextSemesterCompare))) {
            nextSemesterCompare = cmp;
            nextSemester.slug = semester.slug;
          }
        });
      });
      $scope.nextSemester = nextSemester;
      $scope.previousSemester = previousSemester;
      $scope.previousNextSemesterShow = (nextSemesterCompare || previousSemesterCompare);
    };

    var findSemester = function(semesters, slug, selectedSemester) {
      if (selectedSemester || !semesters) {
        return selectedSemester;
      }

      for (var i = 0; i < semesters.length; i++) {
        if (semesters[i].slug === slug) {
          return semesters[i];
        }
      }
    };

    var getClassesSections = function(courses, findWaitlisted) {
      var classes = [];

      for (var i = 0; i < courses.length; i++) {
        var course = courses[i];
        var sections = [];
        for (var j = 0; j < course.sections.length; j++) {
          var section = course.sections[j];
          if ((findWaitlisted && section.waitlistPosition) || (!findWaitlisted && !section.waitlistPosition)) {
            sections.push(section);
          }
        }
        if (sections.length) {
          if (findWaitlisted) {
            var courseCopy = angular.copy(course);
            courseCopy.sections = sections;
            classes.push(courseCopy);
          } else {
            classes = classes.concat(splitMultiplePrimaries(course, sections));
          }
        }
      }

      return classes;
    };

    var getAllClasses = function(semesters) {
      var classes = [];
      for (var i = 0; i < semesters.length; i++) {
        for (var j = 0; j < semesters[i].classes.length; j++) {
          if (semesters[i].timeBucket !== 'future') {
            classes.push(semesters[i].classes[j]);
          }
        }
      }

      return classes;
    };

    var getPreviousClasses = function(semesters) {
      var classes = [];
      for (var i = 0; i < semesters.length; i++) {
        for (var j = 0; j < semesters[i].classes.length; j++) {
          if (semesters[i].timeBucket !== 'future' && semesters[i].timeBucket !== 'current') {
            classes.push(semesters[i].classes[j]);
          }
        }
      }

      return classes;
    };

    // Selects the semester of most pressing interest. Choose the current semester if available.
    // Otherwise choose the next semester in the future, if available.
    // Otherwise,choose the most recent semester.
    var chooseDefaultSemester = function(semesters) {
      var oldestFutureSemester = false;
      for (var i = 0; i < semesters.length; i++) {
        if (semesters[i].timeBucket === 'current') {
          return semesters[i];
        } else if (semesters[i].timeBucket === 'future') {
          oldestFutureSemester = semesters[i];
        } else {
          if (oldestFutureSemester) {
            return oldestFutureSemester;
          } else {
            return semesters[i];
          }
        }
      }
      return oldestFutureSemester;
    };

    var hasTeachingClasses = function(teachingSemesters) {
      if (teachingSemesters) {
        for (var i = 0; i < teachingSemesters.length; i++) {
          var semester = teachingSemesters[i];
          if (semester.classes.length > 0) {
            return true;
          }
        }
      }
      return false;
    };

    var countSectionItem = function(selectedCourse, sectionItem) {
      var count = 0;
      for (var i = 0; i < selectedCourse.sections.length; i++) {
        if (selectedCourse.sections[i][sectionItem] && selectedCourse.sections[i][sectionItem].length) {
          count += selectedCourse.sections[i][sectionItem].length;
        }
      }
      return count;
    };

    var initMultiplePrimaries = function(course) {
      var primariesCount = 0;
      angular.forEach(course.sections, function(section) {
        if (section.is_primary_section) {
          // Copy the first section's grading information to the course for
          // easier processing later.
          if (primariesCount === 0) {
            course.gradeOption = section.gradeOption;
            course.units = section.units;
          }
          primariesCount++;
        }
      });
      course.multiplePrimaries = (primariesCount > 1);
    };

    var splitMultiplePrimaries = function(originalCourse, enrolledSections) {
      var classes = [];
      var course = angular.copy(originalCourse);
      course.sections = [];
      var hasPrimary = false;
      for (var i = 0; i < enrolledSections.length; i++) {
        var section = enrolledSections[i];
        if (section.is_primary_section) {
          if (hasPrimary) {
            classes.push(course);
            course = angular.copy(originalCourse);
            course.sections = [];
            hasPrimary = false;
          }
          course.gradeOption = section.gradeOption;
          course.units = section.units;
          hasPrimary = true;
        }
        course.sections.push(section);
      }
      classes.push(course);
      return classes;
    };

    var pastSemestersCount = function(semesters) {
      var count = 0;

      if (semesters && semesters.length) {
        for (var i = 0; i < semesters.length; i++) {
          if (semesters[i].timeBucket === 'past') {
            count++;
          }
        }
      }
      return count;
    };

    var isLSStudent = function(collegeAndLevel) {
      if (!collegeAndLevel || !collegeAndLevel.colleges) {
        return false;
      }

      for (var i = 0; i < collegeAndLevel.colleges.length; i++) {
        if (collegeAndLevel.colleges[i].college === 'College of Letters & Science') {
          return true;
        }
      }
    };

    var fillSemesterSpecificPage = function(semesterSlug, data) {
      var isOnlyInstructor = !!$routeParams.teachingSemesterSlug;
      var selectedStudentSemester = findSemester(data.semesters, semesterSlug, selectedStudentSemester);
      var selectedTeachingSemester = findSemester(data.teachingSemesters, semesterSlug, selectedTeachingSemester);
      var selectedSemester = (selectedStudentSemester || selectedTeachingSemester);
      if (!checkPageExists(selectedSemester)) {
        return;
      }
      var selectedTelebears = findSemester(data.telebears, semesterSlug, selectedTelebears);
      updatePrevNextSemester([data.semesters, data.teachingSemesters], selectedSemester);

      $scope.selectedSemester = selectedSemester;
      if (selectedStudentSemester && !$routeParams.classSlug) {
        $scope.selectedCourses = selectedStudentSemester.classes;
        if (!isOnlyInstructor) {
          $scope.allCourses = getAllClasses(data.semesters);
          $scope.previousCourses = getPreviousClasses(data.semesters);
          $scope.enrolledCourses = getClassesSections(selectedStudentSemester.classes, false);
          $scope.waitlistedCourses = getClassesSections(selectedStudentSemester.classes, true);
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
            initMultiplePrimaries(course);
            $scope.selectedCourse = course;
            if (isOnlyInstructor) {
              $scope.campusCourseId = course.listings[0].course_id;
            }
            break;
          }
        }
        if (!checkPageExists($scope.selectedCourse)) {
          return;
        }
        $scope.selectedCourseCountInstructors = countSectionItem($scope.selectedCourse, 'instructors');
        $scope.selectedCourseCountSchedules = countSectionItem($scope.selectedCourse, 'schedules');
      }
    };

    var parseAcademics = function(data) {
      angular.extend($scope, data);

      $scope.semesters = data.semesters;

      if (data.semesters) {
        $scope.pastSemestersCount = pastSemestersCount(data.semesters);
        $scope.pastSemestersLimit = data.semesters.length - $scope.pastSemestersCount + 1;
        if (data.additionalCredits) {
          $scope.pastSemestersCount++;
        }
      }

      $scope.isLSStudent = isLSStudent($scope.collegeAndLevel);
      $scope.isUndergraduate = ($scope.collegeAndLevel && $scope.collegeAndLevel.standing === 'Undergraduate');

      $scope.isAcademicInfoAvailable = !!($scope.semesters.length || $scope.requirements.length || $scope.studentInfo.regStatus.code !== null);
      $scope.showProfileMessage = (!$scope.collegeAndLevel.standing || $scope.transitionRegStatus);

      $scope.hasTeachingClasses = hasTeachingClasses(data.teachingSemesters);
      if (data.teachingSemesters) {
        $scope.pastSemestersTeachingCount = pastSemestersCount(data.teachingSemesters);
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
          $scope.selectedTeachingSemester = chooseDefaultSemester(data.teachingSemesters);
          $scope.widgetSemesterName = $scope.selectedTeachingSemester.name;
        }
      }
      $scope.gpaUnits.cumulativeGpaFloat = $scope.gpaUnits.cumulativeGpa; // cumulativeGpa is passed as a string to maintain two significant digits
      $scope.gpaUnits.cumulativeGpa =  parseFloat($scope.gpaUnits.cumulativeGpa); // converted to Float to be processed regularly
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
