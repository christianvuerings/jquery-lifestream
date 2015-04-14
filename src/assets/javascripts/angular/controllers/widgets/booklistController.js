/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Textbook controller
   */
  angular.module('calcentral.controllers').controller('BooklistController', function(academicsService, textbookFactory, $routeParams, $scope, $q) {
    $scope.semesterBooks = [];
    var requests = [];

    var getTextbook = function(courseInfo, courseNumber) {
      return textbookFactory.getTextbooks({
        params: courseInfo
      })
      .success(function(books) {
        books.course = courseNumber;
        $scope.semesterBooks.push(books);
        $scope.semesterBooks.sort(function(a, b) {
          return a.course.localeCompare(b.course);
        });
      });
    };

    var returnSection = function(section) {
      return section.section_number;
    };

    var addToRequests = function(semester) {
      var enrolledCourses = academicsService.getClassesSections(semester.classes, false);
      var waitlistedCourses = academicsService.getClassesSections(semester.classes, true);
      var courses = enrolledCourses.concat(waitlistedCourses);

      for (var c = 0; c < courses.length; c++) {
        // get textbooks for each course
        var selectedCourse = courses[c];
        var sectionNumbers = selectedCourse.sections.map(returnSection);

        var courseInfo = {
          'sectionNumbers[]': sectionNumbers,
          'department': selectedCourse.dept,
          'courseCatalog': selectedCourse.courseCatalog,
          'slug': semester.slug
        };

        var courseTitle = selectedCourse.course_code;
        if (selectedCourse.multiplePrimaries) {
          courseTitle = courseTitle + ' ' + selectedCourse.sections[0].section_label;
        }

        requests.push(getTextbook(courseInfo, courseTitle));
      }
    };

    var getSemesterTextbooks = function(semesters) {
      var semester = academicsService.findSemester(semesters, $routeParams.semesterSlug);
      addToRequests(semester);

      $scope.semesterName = semester.name;
      $scope.semesterSlug = semester.slug;

      $q.all(requests).then(function() {
        $scope.isLoading = false;
      });
    };

    $scope.$watchCollection('[$parent.semesters, api.user.profile.features.textbooks]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        getSemesterTextbooks(returnValues[0]);
      }
    });
  });
})(window.angular);
