/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas roster photos LTI app controller
   */
  angular.module('calcentral.controllers').controller('RosterController', function(apiService, rosterFactory, $routeParams, $scope, $window) {
    if ($routeParams.canvasCourseId) {
      apiService.util.setTitle('Roster Photos');
    }

    $scope.updateFilterDescription = function() {
      var textSearch = '';
      var sectionDesc = '';
      if ($scope.search && $scope.search.$) {
        textSearch = ' - Text Search: ' + $scope.search.$;
      }
      if ($scope.searchSection) {
        sectionDesc = $scope.searchSection.name;
      } else {
        sectionDesc = 'All Sections';
      }
      $scope.filterDescription = sectionDesc + textSearch;
    };

    $scope.studentInSectionFilter = function(student) {
      if (!$scope.searchSection) {
        return true;
      }
      return (student.section_ccns.indexOf($scope.searchSection.ccn) !== -1);
    };

    var getRoster = function() {
      $scope.context = $scope.campusCourseId ? 'campus' : 'canvas';
      $scope.courseId = $scope.campusCourseId || $routeParams.canvasCourseId || 'embedded';
      $scope.origin = $window.location.origin;

      rosterFactory.getRoster($scope.context, $scope.courseId).success(function(data) {
        angular.extend($scope, data);
        $scope.course = $scope[$scope.context + '_course'];
        apiService.util.iframeUpdateHeight();
        $scope.updateFilterDescription();
      }).error(function(data, status) {
        angular.extend($scope, data);
        $scope.errorStatus = status;
      });
    };

    getRoster();
  });
})(window.angular);
