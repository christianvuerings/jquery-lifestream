(function(angular) {
  'use strict';

  /**
   * Photo controller
   */
  angular.module('calcentral.controllers').controller('ProfileController', function(apiService, $scope) {

    apiService.util.setTitle('Profile');

    $scope.profilePictureLoading = true;

  });

})(window.angular);
