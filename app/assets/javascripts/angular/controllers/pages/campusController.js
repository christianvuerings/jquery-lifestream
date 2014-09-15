(function(angular) {
  'use strict';

  /**
   * Campus controller
   */
  angular.module('calcentral.controllers').controller('CampusController', function($routeParams, $scope, apiService, campusLinksFactory) {

    campusLinksFactory.getLinks({
      category: $routeParams.category
    }).then(function(data) {
      angular.extend($scope, data);

      if (data.currentTopCategory) {
         // Set the page title
        var title = 'Campus - ' + data.currentTopCategory;
        apiService.util.setTitle(title);
      }
    });

  });

})(window.angular);
