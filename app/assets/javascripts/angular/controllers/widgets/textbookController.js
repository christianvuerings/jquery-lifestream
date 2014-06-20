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
        'slug': $scope.selectedSemester.slug
      };

      // $http.get('/dummy/json/textbooks_details.json').success(function(data) {
      $http.get('/api/my/textbooks_details', {
        params: courseInfo
      }).success(function(data) {
        angular.extend($scope, data);

        if (data.books && data.books.hasBooks) {
          $scope.allSectionsHaveChoices = true;
          var bookDetails = data.books.bookDetails;

          for (var i = 0; i < bookDetails.length; i++) {
            if (!bookDetails[i].hasChoices) {
              $scope.allSectionsHaveChoices = false;
              break;
            }
          }
        }

        if (data.statusCode && data.statusCode >= 400) {
          $scope.textbookError = data;
        }
      });
    };

    $scope.$watchCollection('[$parent.selectedCourse, api.user.profile.features.textbooks]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        getTextbooks(returnValues[0]);
      }
    });

  });

})(window.angular);
