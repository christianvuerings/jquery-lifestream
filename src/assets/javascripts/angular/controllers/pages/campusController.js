'use strict';

var angular = require('angular');

/**
 * Campus controller
 */
angular.module('calcentral.controllers').controller('CampusController', function(apiService, campusLinksFactory, $routeParams, $scope) {
  campusLinksFactory.getLinks({
    category: $routeParams.category
  }).then(function(data) {
    if (data && data.currentTopCategory) {
      // Set the page title
      var title = 'Campus - ' + data.currentTopCategory;
      apiService.util.setTitle(title);

      angular.extend($scope, data);
    }
  });
});
