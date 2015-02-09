(function(angular) {
  'use strict';

  /**
   * Canvas 'Create a Site' overview index controller
   */
  angular.module('calcentral.controllers').controller('CanvasSiteCreationController', function(apiService, canvasSiteCreationFactory, $location, $route, $scope) {
    apiService.util.setTitle('Create a Site Overview');

    $scope.accessDeniedError = 'This feature is only available to faculty and staff.';
    $scope.linkToCreateCourseSite = $route.current.isEmbedded ? '/canvas/embedded/create_course_site' : '/canvas/create_course_site';
    $scope.linkToCreateProjectSite = $route.current.isEmbedded ? '/canvas/embedded/create_project_site' : '/canvas/create_project_site';

    var loadAuthorizations = function() {
      canvasSiteCreationFactory.getAuthorizations()
        .success(function(data) {
          if (!data && (typeof(data.authorizations.canCreateCourseSite) === 'undefined') || (typeof(data.authorizations.canCreateProjectSite) === 'undefined')) {
            $scope.authorizationError = 'failure';
          } else {
            angular.extend($scope, data);
            if ($scope.authorizations.canCreateCourseSite === false && $scope.authorizations.canCreateProjectSite === false) {
              $scope.authorizationError = 'unauthorized';
            }
          }
        })
        .error(function() {
          $scope.authorizationError = 'failure';
        });
    };

    loadAuthorizations();
  });
})(window.angular);
