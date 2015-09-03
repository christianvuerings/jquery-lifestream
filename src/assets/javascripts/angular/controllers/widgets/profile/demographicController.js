'use strict';

var angular = require('angular');

/**
 * Demographic controller
 */
angular.module('calcentral.controllers').controller('DemographicController', function(profileFactory, $scope) {
  var loadInformation = function() {
    profileFactory.getPerson().then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
