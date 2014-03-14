(function(angular) {
  'use strict';

  /**
   * Academics controller
   */
  angular.module('calcentral.controllers').controller('AcademicsController', function(apiService, $http, $routeParams, $scope, $q) {

    apiService.util.setTitle('My Academics');

    var gradeOptions = [
      {
        grade: 'A+',
        weight: 4
      },
      {
        grade: 'A',
        weight: 4
      },
      {
        grade: 'A-',
        weight: 3.7
      },
      {
        grade: 'B+',
        weight: 3.3
      },
      {
        grade: 'B',
        weight: 3
      },
      {
        grade: 'B-',
        weight: 2.7
      },
      {
        grade: 'C+',
        weight: 2.3
      },
      {
        grade: 'C',
        weight: 2
      },
      {
        grade: 'C-',
        weight: 1.7
      },
      {
        grade: 'D+',
        weight: 1.3
      },
      {
        grade: 'D',
        weight: 1
      },
      {
        grade: 'D-',
        weight: 0.7
      },
      {
        grade: 'F',
        weight: 0
      }
    ];

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
      var selectedSemesterCompare = selectedSemester.term_yr + selectedSemester.term_cd;
      angular.forEach(semestersLists, function(semesterList) {
        angular.forEach(semesterList, function(semester) {
          var cmp = semester.term_yr + semester.term_cd;
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
        var course = angular.copy(courses[i]);
        var sections = [];
        for (var j = 0; j < course.sections.length; j++) {
          var section = course.sections[j];
          if ((findWaitlisted && section.waitlist_position) || (!findWaitlisted && !section.waitlist_position)) {
            sections.push(section);
          }
        }
        if (sections.length) {
          course.sections = sections;
          classes.push(course);
        }
      }

      return classes;
    };

    var getAllClasses = function(semesters) {
      var classes = [];
      for (var i = 0; i < semesters.length; i++) {
        for (var j = 0; j < semesters[i].classes.length; j++) {
          if (semesters[i].time_bucket !== 'future') {
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
          if (semesters[i].time_bucket !== 'future' && semesters[i].time_bucket !== 'current') {
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

    var parseTeaching = function(teaching_semesters) {

      if (!teaching_semesters) {
        return {};
      }

      var teaching = {};
      for (var i = 0; i < teaching_semesters.length; i++) {
        var semester = teaching_semesters[i];
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

    var countSectionItem = function(selected_course, sectionItem) {
      var count = 0;
      for (var i = 0; i < selected_course.sections.length; i++) {
        if (selected_course.sections[i][sectionItem] && selected_course.sections[i][sectionItem].length) {
          count += selected_course.sections[i][sectionItem].length;
        }
      }
      return count;
    };

    var parseAcademics = function(data) {
      angular.extend($scope, data);

      $scope.semesters = data.semesters;

      $scope.allCourses = getAllClasses(data.semesters);
      $scope.previousCourses = getPreviousClasses(data.semesters);

      $scope.isUndergraduate = ($scope.college_and_level && $scope.college_and_level.standing === 'Undergraduate');

      $scope.teaching = parseTeaching(data.teaching_semesters);
      $scope.teachingLength = Object.keys($scope.teaching).length;

      // Get selected semester from URL params and extract data from semesters array
      var semesterSlug = ($routeParams.semesterSlug || $routeParams.teachingSemesterSlug);
      if (semesterSlug) {
        var isInstructorOrGsi = !!$routeParams.teachingSemesterSlug;
        var selectedStudentSemester = findSemester(data.semesters, semesterSlug, selectedStudentSemester);
        var selectedTeachingSemester = findSemester(data.teaching_semesters, semesterSlug, selectedTeachingSemester);
        var selectedSemester = (selectedStudentSemester || selectedTeachingSemester);
        if (!checkPageExists(selectedSemester)) {
          return;
        }
        updatePrevNextSemester([data.semesters, data.teaching_semesters], selectedSemester);

        $scope.selectedSemester = selectedSemester;
        if (selectedStudentSemester) {
          $scope.selectedCourses = selectedStudentSemester.classes;
          if (!isInstructorOrGsi) {
            $scope.enrolledCourses = getClassesSections(selectedStudentSemester.classes, false);
            $scope.waitlistedCourses = getClassesSections(selectedStudentSemester.classes, true);
          }
        }
        $scope.selectedStudentSemester = selectedStudentSemester;
        $scope.isInstructorOrGsi = isInstructorOrGsi;
        $scope.selectedTeachingSemester = selectedTeachingSemester;

        // Get selected course from URL params and extract data from selected semester schedule
        if ($routeParams.classSlug) {
          var classSemester = selectedStudentSemester;
          if (isInstructorOrGsi) {
            classSemester = selectedTeachingSemester;
          }
          for (var i = 0; i< classSemester.classes.length; i++) {
            var course = classSemester.classes[i];
            if (course.slug === $routeParams.classSlug) {
              $scope.selected_course = course;
              if (isInstructorOrGsi) {
                $scope.campusCourseId = course.course_id;
              }
              break;
            }
          }
          if (!checkPageExists($scope.selected_course)) {
            return;
          }
          $scope.selectedCourseCountInstructors = countSectionItem($scope.selected_course, 'instructors');
          $scope.selectedCourseCountSchedules = countSectionItem($scope.selected_course, 'schedules');
        }
      }

      parseExamSchedule(data.exam_schedule);

      $scope.gpaInit(); // Initialize GPA calculator with selected courses

      $scope.telebears = data.telebears;

    };

    $scope.currentSelection = 'Class Info';
    $scope.selectOptions = ['Class Info', 'Class Roster'];

    $scope.switchSelectedOption = function(selectedOption) {
      $scope.currentSelection = selectedOption;
    };

    $scope.addTelebearsAppointment = function(phasesArray) {
      var phases = [];
      $scope.telebearsAppointmentLoading = 'Process';
      for (var i = 0; i < phasesArray.length; i++) {
        var payload = {
          'summary': phasesArray[i].period,
          'start': {
            'epoch': phasesArray[i].startTime.epoch
          },
          'end': {
            'epoch': phasesArray[i].endTime.epoch
          }
        };
        apiService.analytics.sendEvent('Telebears', 'Add Appointment', 'Phase: ' + payload.summary);
        phases.push($http.post('/api/my/event', payload));
      }
      $q.all(phases).then(function() {
        $scope.telebearsAppointmentLoading = 'Success';
      }, function() {
        $scope.telebearsAppointmentLoading = 'Error';
      });
    };

    $scope.hideDisclaimer = true;

    $scope.toggleBlockHistory = function() {
      $scope.showBlockHistory = !$scope.showBlockHistory;
      apiService.analytics.sendEvent('Block history', 'Show history panel - ' + $scope.showBlockHistory ? 'Show' : 'Hide');
    };

    $scope.gradeOptions = gradeOptions;

    var findWeight = function(grade) {
      var weight = gradeOptions.filter(function(element) {
        return element.grade === grade;
      });
      return weight[0];
    };

    var gpaCalculate = function() {
      // Recalculate GPA on every dropdown change.
      var totalUnits = 0;
      var totalScore = 0;

      angular.forEach($scope.selectedCourses, function(course) {
        // Don't calculate for pass/no-pass courses!
        if (course.grade_option === 'Letter' && course.units) {
          var grade;
          if (course.grade && findWeight(course.grade)) {
            grade = findWeight(course.grade).weight;
          } else {
            grade = course.estimatedGrade;
          }
          course.score = parseFloat(grade, 10) * course.units;
          totalUnits += parseFloat(course.units, 10);
          totalScore += course.score;
        }
      });
      $scope.estimatedGpa = totalScore / totalUnits;
    };

    $scope.gpaUpdateCourse = function(course, estimatedGrade) {
      // Update course object on scope and recalculate overall GPA
      course.estimatedGrade = estimatedGrade;
      gpaCalculate();
      cumulativeGpaCalculate($scope.allCourses, 'estimated');
    };

    $scope.gpaInit = function() {
      // On page load, set default values and calculate starter GPA
      angular.forEach($scope.selectedCourses, function(course) {
        course.estimatedGrade = 4;
      });
      gpaCalculate();
      cumulativeGpaCalculate($scope.previousCourses, 'current');
      cumulativeGpaCalculate($scope.allCourses, 'estimated');
    };

    var cumulativeGpaCalculate = function(courses, gpaType) {
      // Recalculate GPA on every dropdown change.
      var totalUnits = 0;
      var totalScore = 0;
      angular.forEach(courses, function(course) {
        // Don't calculate for pass/no-pass courses!
        if (course.grade_option === 'Letter' && course.units) {
          var grade;
          if (course.grade && findWeight(course.grade)) {
            grade = findWeight(course.grade).weight;
          } else {
            if (gpaType === 'estimated') {
              grade = course.estimatedGrade;
            }
          }
          if (grade || grade === 0) {
            course.score = parseFloat(grade, 10) * course.units;
            totalUnits += parseFloat(course.units, 10);
            totalScore += course.score;
          }
        }
      });
      if (gpaType === 'estimated') {
        $scope.estimatedCumulativeGpa = totalScore / totalUnits;
      }
      else {
        $scope.currentCumulativeGpa = totalScore / totalUnits;
      }
    };

    // Wait until user profile is fully loaded before hitting academics data
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        $scope.canViewAcademics = $scope.api.user.profile.student_info.has_academics_tab;
        $http.get('/api/my/academics').success(parseAcademics);
        //$http.get('/dummy/json/academics.json').success(parseAcademics);
      }
    });

  });
})(window.angular);
