/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Academics controller
   */
  angular.module('calcentral.controllers').controller('AcademicsController', function(academicsFactory, apiService, badgesFactory, $http, $routeParams, $scope) {

    apiService.util.setTitle('My Academics');

    /**
     * We're putting the exams in buckets per date
     */
    var parseExamSchedule = function(examSchedule) {

      if (!examSchedule) {
        return;
      }

      var response = {};
      angular.forEach(examSchedule, function(element) {
        if (!response[element.date.epoch]) {
          response[element.date.epoch] = [];
        }
        response[element.date.epoch].push(element);
      });
      $scope.examSchedule = response;
      $scope.examScheduleLength = Object.keys(response).length;
    };

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

    var findTeachingSemester = function(semesters, semester) {
      for (var i = 0; i < semesters.length; i++) {
        if (semester.slug === semesters[i].slug) {
          return true;
        }
      }
      return false;
    };

    var parseTeaching = function(teachingSemesters) {

      if (!teachingSemesters) {
        return {};
      }

      var teaching = {};
      for (var i = 0; i < teachingSemesters.length; i++) {
        var semester = teachingSemesters[i];
        for (var j = 0; j < semester.classes.length; j++) {
          var course = semester.classes[j];
          if (!teaching[course.slug]) {
            teaching[course.slug] = {
              course_code: course.course_code,
              title: course.title,
              slug: course.slug,
              semesters: []
            };
          }
          var semesterItem = {
            name: semester.name,
            slug: semester.slug
          };
          if (!findTeachingSemester(teaching[course.slug].semesters, semesterItem)) {
            teaching[course.slug].semesters.push(semesterItem);
          }
        }
      }
      return teaching;

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

    var parseAcademics = function(data) {
      angular.extend($scope, data);

      $scope.semesters = data.semesters;

      if (data.semesters) {
        $scope.pastSemestersCount = pastSemestersCount(data.semesters);
        $scope.pastSemestersLimit = data.semesters.length - $scope.pastSemestersCount + 1;
      }

      $scope.isLSStudent = isLSStudent($scope.collegeAndLevel);
      $scope.isUndergraduate = ($scope.collegeAndLevel && $scope.collegeAndLevel.standing === 'Undergraduate');

      $scope.teaching = parseTeaching(data.teachingSemesters);
      $scope.teachingLength = Object.keys($scope.teaching).length;
      if (data.teachingSemesters) {
        $scope.pastSemestersTeachingCount = pastSemestersCount(data.teachingSemesters);
        $scope.pastSemestersTeachingLimit = data.teachingSemesters.length - $scope.pastSemestersTeachingCount + 1;
      }

      // Get selected semester from URL params and extract data from semesters array
      var semesterSlug = ($routeParams.semesterSlug || $routeParams.teachingSemesterSlug);
      if (semesterSlug) {
        var isOnlyInstructor = !!$routeParams.teachingSemesterSlug;
        var selectedStudentSemester = findSemester(data.semesters, semesterSlug, selectedStudentSemester);
        var selectedTeachingSemester = findSemester(data.teachingSemesters, semesterSlug, selectedTeachingSemester);
        var selectedSemester = (selectedStudentSemester || selectedTeachingSemester);
        if (!checkPageExists(selectedSemester)) {
          return;
        }
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
                $scope.campusCourseId = course.course_id;
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
      }

      parseExamSchedule(data.examSchedule);

      $scope.telebears = data.telebears;

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
        });
      }
    });

  });
})(window.angular);
