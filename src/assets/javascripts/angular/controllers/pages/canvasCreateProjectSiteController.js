(function(angular) {
  'use strict';

  /**
   * Canvas 'Create a Site' overview index controller
   */
  angular.module('calcentral.controllers').controller('CanvasCreateProjectSiteController', function(apiService, canvasSiteCreationFactory, $scope) {
    apiService.util.setTitle('Create a Project Site');

    $scope.accessDeniedError = "This feature is only available to faculty and staff.";

    var loadAuthorization = function() {
      canvasSiteCreationFactory.getAuthorizations()
        .success(function(data) {
          console.log(data);
          if (!data && (typeof(data.authorizations.canCreateProjectSite) === 'undefined')) {
            $scope.authorizationError = 'failure';
          } else {
            angular.extend($scope, data);
            if ($scope.authorizations.canCreateProjectSite === false) {
              $scope.authorizationError = 'unauthorized';
            }
          }
        })
        .error(function() {
          $scope.authorizationError = 'failure';
        });
    };

    loadAuthorization();
  });
})(window.angular);
