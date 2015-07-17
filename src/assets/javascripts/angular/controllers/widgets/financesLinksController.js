'use strict';

var angular = require('angular');

/**
 * Footer controller
 */
angular.module('calcentral.controllers').controller('FinancesLinksController', function(campusLinksFactory, $scope) {
  campusLinksFactory.getLinks({
    category: 'finances'
  }).then(function(data) {
    angular.extend($scope, data);
  });
});
