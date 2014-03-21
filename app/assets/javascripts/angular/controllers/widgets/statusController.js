(function(angular) {
  'use strict';

  /**
   * Status controller
   */
  angular.module('calcentral.controllers').controller('StatusController', function(badgesFactory, $scope) {

    var loadStudentInfo = function(studentInfo) {
      $scope.studentInfo = studentInfo;
      $scope.showStatusError = studentInfo &&
        studentInfo.californiaResidency &&
        (studentInfo.californiaResidency.needsAction ||
        studentInfo.regBlock.needsAction);
    };

    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        badgesFactory.getBadges().success(function(data) {
          loadStudentInfo(data.studentInfo);
        });
      }
    });

  });

})(window.angular);
