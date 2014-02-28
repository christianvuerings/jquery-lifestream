(function(angular) {
  'use strict';

  /**
   * My Groups controller
   */
  angular.module('calcentral.controllers').controller('MyGroupsController', function($http, $routeParams, $scope, apiService) {

    var getMyGroups = function() {
      $http.get('/api/my/groups').success(function(data) {
        apiService.updatedFeeds.feedLoaded(data);
        angular.extend($scope, data);
      });
    };

    var getResearch = function() {
      var linkDataUrl = '/api/my/research';
      $http.get(linkDataUrl).success(function(data) {
        angular.extend($scope, data);
      });
    };

    $scope.$watch('api.user.profile.features.research', function(researchFeature) {
      if (researchFeature === true) {
        getResearch();
      }
    });

    $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
      if (services && services['MyGroups::Merged']) {
        getMyGroups();
      }
    });
    getMyGroups();
  });

})(window.angular);
