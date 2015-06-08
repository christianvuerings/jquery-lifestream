(function(angular) {
  'use strict';

  /**
   * Webcast controller
   */
  angular.module('calcentral.controllers').controller('WebcastController', function(apiService, webcastFactory, $route, $routeParams, $scope) {
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

    var setSelectedOption = function() {
      var audioOnly = $scope.audio && (!$scope.videos || $scope.videos.length == 0)
      if (audioOnly) {
        $scope.switchSelectedOption($scope.selectOptions[1]);
      } else {
        $scope.switchSelectedOption($scope.selectOptions[0]);
      }
    };

    var getWebcasts = function(title) {
      webcastFactory.getWebcasts({
        url: webcastUrl(title)
      }).success(function(data) {
        angular.extend($scope, data);
        selectFirstOptions();
        setSelectedOption();
      });
    };

    var formatClassTitle = function() {
      var courseYear = encodeURIComponent($scope.selectedSemester.termYear);
      var courseSemester = encodeURIComponent($scope.selectedSemester.termCode);
      var courseDepartment = encodeURIComponent($scope.selectedCourse.dept);
      var courseCatalog = encodeURIComponent($scope.selectedCourse.courseCatalog);
      var title = courseYear + '/' +
                  courseSemester + '/' +
                  apiService.util.encodeSlash(courseDepartment) + '/' +
                  apiService.util.encodeSlash(courseCatalog);
      getWebcasts(title);
    };

    $scope.switchSelectedOption = function(selectedOption) {
      $scope.currentSelection = selectedOption;
    };

    var setSelectOptions = function() {
      var options = ['Video', 'Audio'];
      $scope.selectOptions = options;
    };

    if ($routeParams.canvasCourseId || $route.current.isEmbedded) {
      courseMode = 'canvas';
      var canvasCourseId;
      if ($route.current.isEmbedded) {
        canvasCourseId = 'embedded';
        $scope.isEmbedded = true;
      } else {
        canvasCourseId = $routeParams.canvasCourseId;
      }
      apiService.util.setTitle('Course Webcasts');
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
