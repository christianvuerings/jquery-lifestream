/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Add User to Course LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseGradeExportController', function(apiService, $http, $scope) {

    apiService.util.setTitle('eGrade Export');

    /**
     * Sends message to parent window to switch to gradebook
     */
    $scope.goToGradebook = function() {
      var gradebookUrl = $scope.parentHostUrl + '/courses/' + $scope.canvasCourseId + '/grades';
      apiService.util.iframeParentLocation(gradebookUrl);
    };

    /**
     * Performs authorization check on user to control interface presentation
     */
    var checkAuthorization = function() {
      var courseUserRolesUri = '/api/academics/canvas/course_user_roles';
      $http({
        url: courseUserRolesUri,
        method: 'GET'
      }).success(function(data) {
        $scope.courseUserRoles = data.roles;
        $scope.canvasCourseId = data.courseId;

        // get iframe parent hostname
        var parser = document.createElement('a');
        parser.href = document.referrer;
        $scope.parentHostUrl = parser.protocol + '//' + parser.host;

        $scope.userAuthorized = userIsAuthorized($scope.courseUserRoles);
        if (!$scope.userAuthorized) {
          $scope.showError = true;
          $scope.errorStatus = 'You must be a teacher in this bCourses course to export to eGrades CSV.';
        }
      }).error(function(data) {
        $scope.userAuthorized = false;
        $scope.showError = true;
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Authorization Check Failed';
        }
      });
    };

    var userIsAuthorized = function(courseUserRoles) {
      return (courseUserRoles.globalAdmin || courseUserRoles.teacher);
    };

    apiService.util.iframeUpdateHeight();
    checkAuthorization();
  });

})(window.angular);
