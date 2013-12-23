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
      var link_data_url = '/api/my/research';
      $http.get(link_data_url).success(function(data) {
        angular.extend($scope, data);
      });
    };

    $scope.$watch('api.user.profile.features.research', function(research_feature) {
      if (research_feature === true) {
        getResearch();
      }
    });

    $scope.$on('calcentral.api.updatedFeeds.update_services', function(event, services) {
      if (services && services.MyGroups) {
        getMyGroups();
      }
    });
    getMyGroups();
  });

})(window.angular);
