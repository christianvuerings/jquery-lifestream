(function(angular) {
  'use strict';

  /**
   * Canvas 'Create a Site' overview index controller
   */
  angular.module('calcentral.controllers').controller('CanvasCreateProjectSiteController', function(apiService) {
    apiService.util.setTitle('Create a Project Site');

    $scope.accessDeniedError = "This feature is only available to faculty and staff.";

  });
})(window.angular);
