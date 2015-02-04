(function(angular) {
  'use strict';

  /**
   * Canvas 'Create a Site' overview index controller
   */
  angular.module('calcentral.controllers').controller('CanvasSiteCreationController', function(apiService, canvasSiteCreationFactory, $route, $scope, $window) {
    apiService.util.setTitle('Create a Site Overview');


    $scope.linkToCreateCourseSite = function() {
      if ($route.current.isEmbedded) {
        $window.location = '/canvas/embedded/create_course_site';
      } else {
        $window.location =  '/canvas/create_course_site';
      }
    };

    $scope.linkToCreateProjectSite = function() {
      if ($route.current.isEmbedded) {
        $window.location = '/canvas/embedded/create_project_site';
      } else {
        $window.location = '/canvas/create_project_site';
      }
    };

    var setAuthorizationError = function(type) {
      $scope.authorizationError = type;
    };

    var loadAuthorizations = function() {
      canvasSiteCreationFactory.getAuthorizations()
        .success(function(data) {
          $scope.feedRequestCompleted = true;
          if (!data && (typeof(data.canCreateCourseSite) === 'undefined' ) || (typeof(data.canCreateProjectSite) === 'undefined' )) {
            setAuthorizationError('failure');
          } else {
            $scope.authorizations = data;
            if ($scope.authorizations.canCreateCourseSite === false && $scope.authorizations.canCreateProjectSite === false) {
              setAuthorizationError('unauthorized');
            } else {
              $scope.authorized = true;
            }
          }
        })
        .error(function() {
          $scope.feedRequestCompleted = true;
          setAuthorizationError('failure');
        });
    };

    loadAuthorizations();
  });
})(window.angular);
