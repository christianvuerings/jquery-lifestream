(function(angular) {
  'use strict';

  /**
   * Photo controller
   */
  angular.module('calcentral.controllers').controller('ProfileController', function(apiService, $scope) {

    apiService.util.setTitle('Profile');

    $scope.$watch('profilePictureLoaded', function(value) {
      if (value) {
        $scope.isLoading = false;
      }
    });

  });

})(window.angular);
