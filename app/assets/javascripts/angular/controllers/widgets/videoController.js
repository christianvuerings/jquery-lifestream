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
      var courseYear = encodeURIComponent($scope.selectedSemester.termYear);
      var courseSemester = encodeURIComponent($scope.selectedSemester.termCode);
      var courseDepartment = encodeURIComponent($scope.selectedCourse.dept);
      var courseCatalog = encodeURIComponent($scope.selectedCourse.course_catalog);
      var title = courseYear + '/' + courseSemester + '/' + courseDepartment + '/' + courseCatalog;
      getVideos(title);
    };

    $scope.$watchCollection('[$parent.selectedCourse.sections, api.user.profile.features.videos]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        formatClassTitle();
      }
    });

  });

})(window.angular);
