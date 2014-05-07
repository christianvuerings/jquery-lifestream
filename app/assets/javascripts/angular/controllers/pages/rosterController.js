(function(angular) {
  'use strict';

  /**
   * Canvas roster photos LTI app controller
   */
  angular.module('calcentral.controllers').controller('RosterController', function(apiService, rosterFactory, $http, $routeParams, $scope) {

    if ($routeParams.canvasCourseId) {
      apiService.util.setTitle('Roster Photos');
    }

    var getRoster = function() {
      var mode = $scope.campusCourseId ? 'campus' : 'canvas';
      var id = $scope.campusCourseId || $routeParams.canvasCourseId || 'embedded';

      rosterFactory.getRoster(mode, id).success(function(data) {
        angular.extend($scope, data);
        apiService.util.iframeUpdateHeight();
      }).error(function(data, status) {
        angular.extend($scope, data);
        $scope.errorStatus = status;
      });
    };

    getRoster();
  });

})(window.angular);
