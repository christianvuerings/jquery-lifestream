/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Academics GPA controller
   */
  angular.module('calcentral.controllers').controller('AcademicsFinalGradesController', function($scope) {

    var hasTranscripts = function() {
      // On page load, set default values and calculate starter GPA
      var response = false;

      var selectedCourses = $scope.selectedCourses;

      for (var i = 0; i < selectedCourses.length; i++) {
        if (selectedCourses[i].transcript) {
          response = true;
          break;
        }
      }
      return response;
    };

    $scope.semesterHasTranscripts = hasTranscripts();
  });

})(window.angular);
