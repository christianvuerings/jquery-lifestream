(function(angular) {
  'use strict';

  /**
   * Canvas 'Create a Site' overview index controller
   */
  angular.module('calcentral.controllers').controller('CanvasSiteCreationController', function(apiService, $route, $scope) {
    apiService.util.setTitle('Create a Site Overview');

    $scope.createCourseSiteUrl = function() {
      if ($route.current.isEmbedded) {
        return '/canvas/embedded/create_course_site';
      } else {
        return '/canvas/create_course_site';
      }
    };

    $scope.createProjectSiteUrl = function() {
      if ($route.current.isEmbedded) {
        return '/canvas/embedded/create_project_site';
      } else {
        return '/canvas/create_project_site';
      }
    };
  });
})(window.angular);
