(function(angular) {
  'use strict';

  /**
   * Campus controller
   */
  angular.module('calcentral.controllers').controller('CampusController', function($routeParams, $scope, apiService, campusLinksFactory) {

    // We need to wait until the user is loaded
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        campusLinksFactory.getLinks($routeParams.category).then(function(data) {
          angular.extend($scope, data);

          // Set the page title
          var title = 'Campus - ' + data.currentTopCategory;
          apiService.util.setTitle(title);
        });
      }
    });

  });

})(window.angular);
