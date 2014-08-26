(function(angular) {
  'use strict';

  /**
   * Photo controller
   */
  angular.module('calcentral.controllers').controller('ProfileController', function(photoFactory, $scope) {

    $scope.profilePictureLoading = true;

    photoFactory.hasPhoto().success(function(data) {
      $scope.hasPhoto = data.hasPhoto;
    });

  });

})(window.angular);
