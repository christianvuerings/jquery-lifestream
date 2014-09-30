/* jshint camelcase: false */
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
      var sectionNumbers = selectedCourse.sections.map(function(section) {
        return section.section_number;
      });

      var courseInfo = {
        'sectionNumbers[]': sectionNumbers,
        'department': selectedCourse.dept,
        'courseCatalog': selectedCourse.courseCatalog,
        'slug': $scope.selectedSemester.slug
      };

      // $http.get('/dummy/json/textbooks_details.json').success(function(data) {
      $http.get('/api/my/textbooks_details', {
        params: courseInfo
      }).success(function(data) {
        angular.extend($scope, data);

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
