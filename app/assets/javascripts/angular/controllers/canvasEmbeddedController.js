(function (calcentral) {
  'use strict';

  /**
   * Canvas embedded LTI tool controller
   */
  calcentral.controller('CanvasEmbeddedController', ['apiService', '$http', '$routeParams', '$scope', function (apiService, $http, $routeParams, $scope) {
    apiService.util.setTitle('Canvas Embedded View');

    var getRoster = function() {
      var canvas_course_id = $routeParams.canvas_course_id || 'embedded';
      $http.get('/api/academics/rosters/canvas/' + canvas_course_id).success(function(data) {
        angular.extend($scope, data);
      });
    };

    getRoster();
  }]);

})(window.calcentral);
