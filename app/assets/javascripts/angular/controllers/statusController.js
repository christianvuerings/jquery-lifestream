(function(calcentral) {
  'use strict';

  /**
   * Status controller
   */
  calcentral.controller('StatusController', ['$scope', function($scope) {

    var showStatusError = function() {
      $scope.showStatusError =
        $scope.api.user.profile.student_info &&
        ($scope.api.user.profile.student_info.reg_status.needsAction ||
        $scope.api.user.profile.student_info.california_residency.needsAction ||
        $scope.api.user.profile.student_info.reg_block.needsAction);
    };

    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        showStatusError();
      }
    });

  }]);

})(window.calcentral);
