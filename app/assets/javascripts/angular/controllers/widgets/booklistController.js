/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Textbook controller
   */
  angular.module('calcentral.controllers').controller('BooklistController', function($http, $routeParams, $scope, $q) {
    $scope.semesterBooks = [];
    var requests = [];

    var getSemester = function(semesters) {
      for (var i = 0; i < semesters.length; i++) {
        var semester = semesters[i];
        if (semester.slug === $routeParams.semesterSlug) {
          return semester;
        }
      }
    };

    var getTextbook = function(courseInfo, courseNumber) {
      return $http.get('/api/my/textbooks_details', {params: courseInfo}).success(function(books) {
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
      for (var c = 0; c < semester.classes.length; c++) {
        // get textbooks for each course
        var selectedCourse = semester.classes[c];
        var sectionNumbers = selectedCourse.sections.map(returnSection);

        var courseInfo = {
          'sectionNumbers[]': sectionNumbers,
          'department': selectedCourse.dept,
          'courseCatalog': selectedCourse.courseCatalog,
          'slug': semester.slug
        };

        requests.push(getTextbook(courseInfo, selectedCourse.course_code));
      }
    };

    var getSemesterTextbooks = function(semesters) {
      var semester = getSemester(semesters);
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
