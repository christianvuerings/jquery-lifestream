/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Textbook controller
   */
  angular.module('calcentral.controllers').controller('TextbookController', function(academicsService, textbookFactory, $q, $scope) {
    /**
     * Get Textbooks for the selected course
     * @param  {Object} selectedCourse Selected Course Object
     */
    var requests = [];
    $scope.bookListsBySection = [];
    $scope.textbooksCount = 0;

    var setErrorBody = function(errorBody) {
      $scope.textbookError = {
        'body': errorBody
      };
    };

    var getTextbook = function(courseInfo, sectionLabel) {
      return textbookFactory.getTextbooks({
        params: courseInfo
      })
        .success(function(data) {
          data.sectionLabel = sectionLabel;
          if (data.statusCode && data.statusCode >= 400) {
            data.errorMessage = data.body;
            $scope.textbookError = data;
          }
          if (data.books && data.books.items) {
            $scope.textbooksCount += data.books.items.length;
          }
          $scope.bookListsBySection.push(data);
          $scope.bookListsBySection.sort(function(a, b) {
            return a.sectionLabel.localeCompare(b.sectionLabel);
          });
        });
    };

    var getCourseTextbooks = function(selectedCourse) {
      var semester = $scope.isInstructorOrGsi ? $scope.selectedTeachingSemester : $scope.selectedStudentSemester;
      var separatedPrimaries = academicsService.getClassesSections(semester.classes, false, selectedCourse.course_code);

      for (var c = 0; c < separatedPrimaries.length; c++) {
        // get textbooks for each primary section
        var course = separatedPrimaries[c];
        var courseInfo = academicsService.textbookRequestInfo(course, semester);
        if (courseInfo) {
          requests.push(getTextbook(courseInfo, course.sections[0].section_label));
        }
      }

      $q.all(requests).then(function() {
        if (!requests.length) {
          setErrorBody('No textbooks list is available for your course sections.');
        } else if (!$scope.textbooksCount && $scope.bookListsBySection.length && $scope.bookListsBySection[0].books) {
          setErrorBody($scope.bookListsBySection[0].books.bookUnavailableError);
        }
        $scope.isLoading = false;
      });
    };

    $scope.$watchCollection('[$parent.selectedCourse, api.user.profile.features.textbooks]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        getCourseTextbooks(returnValues[0]);
      }
    });
  });
})(window.angular);
