(function(angular) {
  'use strict';

  /**
   * Textbook controller
   */
  angular.module('calcentral.controllers').controller('BooklistController', function($http, $scope, $q) {
    $scope.semesterBooks = [];

    var getSemesterTextbooks = function(semesters) {
      var semester;
      for (var s = 0; s < semesters.length; s++) {
        semester = semesters[s];
        if (semester.timeBucket === 'current') {
          break;
        }
      }
      var requests = [];

      function getTextbook(courseInfo, courseNumber) {
        return $http.get('/api/my/textbooks_details', {params: courseInfo}).success(function(books) {
          if (books) {
            books.course = courseNumber;
            $scope.semesterBooks.push(books);
            $scope.semesterBooks.sort(function(a, b) {
              return a.course.localeCompare(b.course);
            });
            $scope.semesterBooks.hasBooks = true;
          }
        });
      }

      for (var c = 0; c < semester.classes.length; c++) {
        // get textbooks for each course
        var ccns = [];
        var selectedCourse = semester.classes[c];
        for (var i = 0; i < selectedCourse.sections.length; i++) {
          ccns.push(selectedCourse.sections[i].ccn);
        }

        var courseInfo = {
          'ccns[]': ccns,
          'slug': semester.slug
        };

        requests.push(getTextbook(courseInfo, semester.classes[c].course_code));
      }
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
