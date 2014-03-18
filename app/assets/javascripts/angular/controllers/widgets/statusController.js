(function(angular) {
  'use strict';

  /**
   * Status controller
   */
  angular.module('calcentral.controllers').controller('StatusController', function($scope) {

    var showStatusError = function() {
      $scope.showStatusError = $scope.studentInfo &&
        $scope.studentInfo.californiaResidency &&
        ($scope.studentInfo.californiaResidency.needsAction ||
        $scope.studentInfo.regBlock.needsAction);
    };

    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        showStatusError();
      }
    });

  });

})(window.angular);
