(function(angular) {
  'use strict';

  /**
   * Video controller
   */
  angular.module('calcentral.controllers').controller('VideoController', function($http, $scope) {

    var getVideos = function(title) {
      $http.get('/api/media/' + title).success(function(data) {
        angular.extend($scope, data);
        if ($scope.videos) {
          $scope.selectedVideo = $scope.videos[0];
        }
      });
    };

    var formatClassTitle = function() {
      var courseDepartment = $scope.selected_course.dept;
      var courseCatalog = $scope.selected_course.course_catalog;
      var courseSemester = $scope.selectedSemester.termCode;
      var courseYear = $scope.selectedSemester.termYear;
      var title = courseYear + '/' + courseSemester + '/' + courseDepartment + '/' + courseCatalog;
      getVideos(title);
    };

    $scope.$watchCollection('[$parent.selected_course.sections, api.user.profile.features.videos]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        formatClassTitle();
      }
    });

  });

})(window.angular);
