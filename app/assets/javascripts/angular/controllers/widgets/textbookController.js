(function(angular) {
  'use strict';

  /**
   * Textbook controller
   */
  angular.module('calcentral.controllers').controller('TextbookController', function($http, $scope) {

    /**
     * Get Textbooks for the selected course
     * @param  {Object} selectedCourse Selected Course Object
     */
    var getTextbooks = function(selectedCourse) {
      var ccns = [];

      for (var i = 0; i < selectedCourse.sections.length; i++) {
        ccns[i] = selectedCourse.sections[i].ccn;
      }

      var courseInfo = {
        'ccns[]': ccns,
        'slug': $scope.selected_semester.slug
      };

      $http.get('/api/my/textbooks_details', {
        params: courseInfo
      }).success(function(data) {
        angular.extend($scope, data);

        if (data.books && data.books.has_books) {
          $scope.allSectionsHaveChoices = true;
          var bookDetails = data.books.book_details;

          for (var i = 0; i < bookDetails.length; i++) {
            if (!bookDetails[i].has_choices) {
              $scope.allSectionsHaveChoices = false;
              break;
            }
          }
        }

        if (data.status_code && data.status_code >= 400) {
          $scope.textbook_error = data;
        }
      });
    };

    $scope.$watchCollection('[$parent.selected_course, api.user.profile.features.textbooks]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        getTextbooks(returnValues[0]);
      }
    });

  });

})(window.angular);
