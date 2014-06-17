(function(angular) {
  'use strict';

  /**
   * Webcast controller
   */
  angular.module('calcentral.controllers').controller('WebcastController', function(apiService, $http, $route, $routeParams, $scope) {
    // Is this for an official campus class or for a Canvas course site?
    var courseMode = 'campus';

    /**
     * Select the first options in the video / audio feed
     */
    var selectFirstOptions = function() {
      if ($scope.videos) {
        $scope.selectedVideo = $scope.videos[0];
      }
      if ($scope.audio) {
        $scope.selectedAudio = $scope.audio[0];
      }
    };

    var webcastUrl = function(courseId) {
      // return '/dummy/json/media.json';
      if (courseMode === 'canvas') {
        return '/api/canvas/media/' + courseId;
      } else {
        return '/api/media/' + courseId;
      }
    };

    var getWebcasts = function(title) {
      $http.get(webcastUrl(title)).success(function(data) {
        angular.extend($scope, data);
        selectFirstOptions();
      });
    };

    var formatClassTitle = function() {
      var courseYear = encodeURIComponent($scope.selectedSemester.termYear);
      var courseSemester = encodeURIComponent($scope.selectedSemester.termCode);
      var courseDepartment = encodeURIComponent($scope.selectedCourse.dept);
      var courseCatalog = encodeURIComponent($scope.selectedCourse.courseCatalog);
      var title = courseYear + '/' + courseSemester + '/' + courseDepartment + '/' + courseCatalog;
      getWebcasts(title);
    };

    $scope.switchSelectedOption = function(selectedOption) {
      $scope.currentSelection = selectedOption;
    };

    var setSelectOptions = function() {
      var options = ['Video', 'Audio'];
      $scope.selectOptions = options;
      $scope.switchSelectedOption(options[0]);
    };

    if ($routeParams.canvasCourseId || $route.current.isEmbedded) {
      courseMode = 'canvas';
      var canvasCourseId = $routeParams.canvasCourseId || 'embedded';
      apiService.util.setTitle('Course Mediacasts');
      getWebcasts(canvasCourseId);
      setSelectOptions();
    } else {
      $scope.$watchCollection('[$parent.selectedCourse.sections, api.user.profile.features.videos]', function(returnValues) {
        if (returnValues[0] && returnValues[1] === true) {
          formatClassTitle();
          setSelectOptions();
        }
      });
    }

  });

})(window.angular);
