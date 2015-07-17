'use strict';

var angular = require('angular');

/**
 * Webcast controller
 */
angular.module('calcentral.controllers').controller('WebcastController', function(apiService, webcastFactory, $route, $routeParams, $scope) {
  // Is this for an official campus class or for a Canvas course site?
  var courseMode = 'campus';
  var outerTabs = ['Webcast Sign-up', 'Webcasts'];
  $scope.accessibilityAnnounce = apiService.util.accessibilityAnnounce;

  /**
   * Select media items from video/audio dropdowns, defaulting to first
   */
  var selectMediaOptions = function() {
    if ($scope.audio) {
      $scope.selectedAudio = $scope.audio[0];
    }
    if ($scope.videos) {
      if ($routeParams.video) {
        for (var i = 0; i < $scope.videos.length; i++) {
          if ($scope.videos[i].youTubeId === $routeParams.video) {
            $scope.selectedVideo = $scope.videos[i];
            break;
          }
        }
      }
      $scope.selectedVideo = $scope.selectedVideo || $scope.videos[0];
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
    var audioOnly = $scope.audio && ($scope.audio.length > 0) && (!$scope.videos || $scope.videos.length === 0);
    if (audioOnly) {
      $scope.switchSelectedOption($scope.selectOptions[1]);
    } else {
      $scope.switchSelectedOption($scope.selectOptions[0]);
    }
    var showSignUpTab = $scope.eligibleForSignUp && $scope.eligibleForSignUp.length > 0;
    $scope.currentTabSelection = showSignUpTab ? outerTabs[0] : outerTabs[1];
  };

  var getWebcasts = function(title) {
    webcastFactory.getWebcasts({
      url: webcastUrl(title)
    }).success(function(data) {
      angular.extend($scope, data);
      selectMediaOptions();
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

  $scope.switchTabOption = function(tabOption) {
    $scope.currentTabSelection = tabOption;
  };

  $scope.switchSelectedOption = function(selectedOption) {
    $scope.accessibilityAnnounce('Loaded ' + selectedOption + ' Webcasts');
    $scope.currentSelection = selectedOption;
  };

  $scope.announceVideoSelect = function() {
    $scope.accessibilityAnnounce('Selected video \'' + $scope.selectedVideo.lecture + '\' loaded');
  };

  $scope.announceAudioSelect = function() {
    $scope.accessibilityAnnounce('Selected audio recording \'' + $scope.selectedAudio.title + '\' loaded');
  };

  var setSelectOptions = function() {
    $scope.outerTabOptions = outerTabs;
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
