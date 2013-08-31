(function(calcentral) {
  'use strict';

  /**
   * Academics controller
   */
  calcentral.controller('AcademicsController', ['apiService', '$http', '$routeParams', '$scope', function(apiService, $http, $routeParams, $scope) {

    apiService.util.setTitle('My Academics');

    var gradeopts = [
      {grade: 'A', weight: 4},
      {grade: 'A-', weight: 3.7},
      {grade: 'B+', weight: 3.3},
      {grade: 'B', weight: 3},
      {grade: 'B-', weight: 2.7},
      {grade: 'C+', weight: 2.3},
      {grade: 'C', weight: 2},
      {grade: 'C-', weight: 1.7},
      {grade: 'D+', weight: 1.3},
      {grade: 'D', weight: 1},
      {grade: 'D-', weight: 0.7},
      {grade: 'F', weight: 0}
    ];

    /**
     * We're putting the exams in buckets per date
     */
    var parseExamSchedule = function() {
      var exam_schedule = {};
      angular.forEach($scope.exam_schedule, function(element) {
        if (!exam_schedule[element.date.epoch]) {
          exam_schedule[element.date.epoch] = [];
        }
        exam_schedule[element.date.epoch].push(element);
      });
      $scope.exam_schedule = exam_schedule;
      $scope.exam_schedule_length = Object.keys(exam_schedule).length;
    };

    var checkPageExists = function(page) {
      if (!page) {
        apiService.util.redirect('404');
        return;
      }
    };

    var updatePrevNextSemester = function(semesters, selected_semester) {
      var previous_semester = {};
      var next_semester = {};
      var selected_semester_index = false;

      var semesters_length = semesters.length;
      for (var i = 0; i < semesters_length; i++) {
        var element = semesters[i];
        if (element.slug === selected_semester.slug) {
          selected_semester_index = i;
          continue;
        }
        if (element.slug !== selected_semester.slug) {
          if (selected_semester_index === false) {
            next_semester = element;
            continue;
          }
          if (selected_semester_index !== false) {
            previous_semester = element;
            break;
          }
        }
      }
      $scope.previous_semester = previous_semester;
      $scope.next_semester = next_semester;
      $scope.prev_next_semester_show = semesters_length > 1;
    };

    $scope.getAcademics = function() {
      $http.get('/api/my/academics').success(function(data) {
        angular.extend($scope, data);
        $scope.exam_schedule = data.exam_schedule;
        $scope.semesters = data.semesters;
        $scope.selected_course_sections = [];

        // Some users (e.g. test-xxx users) may be missing the "student" role but still need ability to view My Academics pages
        $scope.can_view_academics = $scope.api.user.profile.roles.student || $scope.college_and_level.standing == 'Undergraduate';

        // Get selected semester from URL params and extract data from semesters array
        if ($routeParams.semester_slug) {
          angular.forEach(data.semesters, function(semester) {
            if (semester.slug === $routeParams.semester_slug) {
              $scope.selected_semester = semester;
            }
          });
          checkPageExists($scope.selected_semester);
          updatePrevNextSemester(data.semesters, $scope.selected_semester);

          if ($scope.selected_semester) {
            $scope.selected_courses = $scope.selected_semester.schedule;
            var enrolled_courses = [];
            var waitlisted_courses = [];
            $scope.selected_courses.forEach(function(elt) {
              if (elt.waitlist_pos) {
                waitlisted_courses.push(elt);
              } else {
                enrolled_courses.push(elt);
              }
            });
            $scope.enrolled_courses = enrolled_courses;
            $scope.waitlisted_courses = waitlisted_courses;
          }
        }

        // Get selected course from URL params and extract data from selected semester schedule
        if ($routeParams.course_slug) {
          angular.forEach($scope.selected_semester.schedule, function (course) {
            if (course.slug === $routeParams.course_slug) {
              if ($scope.selected_course == undefined) {
                $scope.selected_course = course;
              }
              $scope.selected_course_sections.push(course);
            }
          });
          checkPageExists($scope.selected_course);

        }

        parseExamSchedule();

        $scope.gpaInit(); // Initialize GPA calculator with selected courses
      });
    };

    $scope.hideDisclaimer = true;

    // Wait until user profile is fully loaded before hitting academics data
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        $scope.getAcademics();
      }
    });

    $scope.toggleBlockHistory = function() {
      $scope.show_block_history = !$scope.show_block_history;
      apiService.analytics.trackEvent(['Block history', 'Show history panel - ' + $scope.show_block_history ? 'Show' : 'Hide']);
    };

    $scope.gradeopts = gradeopts;

    var findWeight = function(grade) {
      var weight = gradeopts.filter(function(element) {
        return element.grade === grade;
      });
      return weight[0];
    };

    var gpaCalculate = function() {
      // Recalculate GPA on every dropdown change.
      var total_units = 0;
      var total_score = 0;

      angular.forEach($scope.selected_courses, function(course) {
        // Don't calculate for pass/no-pass courses!
        if (course.grade_option === 'Letter' && course.units && course.is_primary_section) {
          var grade = course.grade ? findWeight(course.grade).weight : course.estimated_grade;
          course.score = parseFloat(grade, 10) * course.units;
          total_units += parseFloat(course.units, 10);
          total_score += course.score;
        }
      });

      $scope.estimated_gpa = total_score / total_units;
    };

    $scope.gpaUpdateCourse = function(course, estimated_grade) {
      // Update course object on scope and recalculate overall GPA
      course.estimated_grade = estimated_grade;
      gpaCalculate();
    };

    $scope.gpaInit = function() {
      // On page load, set default values and calculate starter GPA
      angular.forEach($scope.selected_courses, function(course) {
        course.estimated_grade = 4;
      });
      gpaCalculate();
    };
  }]);
})(window.calcentral);
