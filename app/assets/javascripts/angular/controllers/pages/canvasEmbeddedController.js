(function (calcentral) {
  'use strict';

  /**
   * Canvas embedded LTI tool controller
   */
  calcentral.controller('CanvasEmbeddedController', ['apiService', '$http', '$routeParams', '$scope', '$window', function (apiService, $http, $routeParams, $scope, $window) {

    apiService.util.setTitle('bCourses Embedded View');

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
      var canvas_course_id = $routeParams.canvas_course_id || 'embedded';
      $http.get('/api/academics/rosters/canvas/' + canvas_course_id).success(function(data) {
        angular.extend($scope, data);
        window.setInterval(postHeight, 250);
      }).error(function(data, status) {
        angular.extend($scope, data);
        $scope.error_status = status;
      });
    };

    getRoster();
  }]);

})(window.calcentral);
