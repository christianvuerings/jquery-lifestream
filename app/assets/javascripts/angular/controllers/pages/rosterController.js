(function(angular) {
  'use strict';

  /**
   * Canvas roster photos LTI app controller
   */
  angular.module('calcentral.controllers').controller('RosterController', function(apiService, $http, $routeParams, $scope, $window) {

    if ($routeParams.canvasCourseId) {
      apiService.util.setTitle('Roster Photos');
    }

    /**
     * Post a message to the parent
     * @param {String|Object} message Message you want to send over.
     */
    var postMessage = function(message) {
      if ($window.parent) {
        $window.parent.postMessage(message, '*');
      }
    };

    var postHeight = function() {
      postMessage({
        height: document.body.scrollHeight
      });
    };

    var getRoster = function() {
      if ($scope.campusCourseId) {
        var campusCourseId = $scope.campusCourseId;
        $http.get('/api/academics/rosters/campus/' + campusCourseId).success(function(data) {
          angular.extend($scope, data);
          window.setInterval(postHeight, 250);
        }).error(function(data, status) {
          angular.extend($scope, data);
          $scope.errorStatus = status;
        });
        return;
      }

      var canvasCourseId = $routeParams.canvasCourseId || 'embedded';
      $http.get('/api/academics/rosters/canvas/' + canvasCourseId).success(function(data) {
        angular.extend($scope, data);
        window.setInterval(postHeight, 250);
      }).error(function(data, status) {
        angular.extend($scope, data);
        $scope.errorStatus = status;
      });
    };

    getRoster();
  });

})(window.angular);
