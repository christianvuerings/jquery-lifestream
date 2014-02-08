(function(angular) {
  'use strict';

  /**
   * Textbook controller
   */
  angular.module('calcentral.controllers').controller('BooklistController', function($http, $scope) {
    $scope.semester_books = [];

    var getSemesterTextbooks = function(semesters) {
      var semester;
      for (var s = 0; s < semesters.length; s++) {
        semester = semesters[s];
        if (semester.time_bucket === 'current') {
          break;
        }
      }

      function getTextbook(course_info, course_number) {
        $http.get('/api/my/textbooks_details', {params: course_info}).success(function(books) {
          if (books) {
            books.course = course_number;
            $scope.semester_books.push(books);
            $scope.semester_books.has_books = true;
          }
        });
      }

      for (var c = 0; c < semester.classes.length; c++) {
        // get textbooks for each course
        var ccns = [];
        var selected_course = semester.classes[c];
        for (var i = 0; i < selected_course.sections.length; i++) {
          ccns.push(selected_course.sections[i].ccn);
        }

        var course_info = {
          'ccns[]': ccns,
          'slug': semester.slug
        };

        getTextbook(course_info, semester.classes[c].course_number);
      }
      $scope.semester_name = semester.name;
      $scope.semester_slug = semester.slug;
    };

    $scope.$watchCollection('[$parent.semesters, api.user.profile.features.textbooks]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        getSemesterTextbooks(returnValues[0]);
      }
    });

  });

})(window.angular);
