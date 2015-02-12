(function(angular) {
  'use strict';

  /**
   * Canvas 'Create a Site' overview index controller
   */
  angular.module('calcentral.controllers').controller('CanvasCreateProjectSiteController', function(apiService, canvasProjectProvisionFactory, canvasSiteCreationFactory, canvasSiteCreationService, $location, $route, $scope, $window) {
    apiService.util.setTitle('Create a Project Site');

    $scope.accessDeniedError = 'This feature is only available to faculty and staff.';
    $scope.linkToSiteOverview = canvasSiteCreationService.linkToSiteOverview($route.current.isEmbedded);

    $scope.disableSubmit = function() {
      return !$scope.projectSiteName || $scope.creatingSite;
    };

    $scope.createProjectSite = function() {
      $scope.creatingSite = true;
      canvasProjectProvisionFactory.createProjectSite($scope.projectSiteName)
        .success(function(data) {
          angular.extend($scope, data);
          if ($scope.projectSiteUrl) {
            if ($route.current.isEmbedded) {
              apiService.util.iframeParentLocation($scope.projectSiteUrl);
            } else {
              $window.location = $scope.projectSiteUrl;
            }
          } else {
            $scope.displayError = 'failure';
          }
        })
        .error(function() {
          $scope.displayError = 'failure';
          $scope.creatingSite = false;
        });
    };

    var loadAuthorization = function() {
      canvasSiteCreationFactory.getAuthorizations()
        .success(function(data) {
          if (!data && (typeof(data.authorizations.canCreateProjectSite) === 'undefined')) {
            $scope.displayError = 'failure';
          } else {
            angular.extend($scope, data);
            if ($scope.authorizations.canCreateProjectSite === false) {
              $scope.displayError = 'unauthorized';
            }
          }
        })
        .error(function() {
          $scope.displayError = 'failure';
        });
    };

    loadAuthorization();
  });
})(window.angular);
