(function(angular) {
  'use strict';

  /**
   * Textbook controller
   */
  angular.module('calcentral.controllers').controller('TextbookController', function($http, $scope) {

    /**
     * Get Textbooks for the selected course
     * @param  {Object} selected_course Selected Course Object
     */
    var getTextbooks = function(selected_course) {
      var ccns = [];

      for (var i = 0; i < selected_course.sections.length; i++) {
        ccns[i] = selected_course.sections[i].ccn;
      }

      var course_info = {
        'ccns[]': ccns,
        'slug': $scope.selected_semester.slug
      };

      $http.get('api/my/textbooks_details', {
        params: course_info
      }).success(function(data) {
        angular.extend($scope, data);

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
