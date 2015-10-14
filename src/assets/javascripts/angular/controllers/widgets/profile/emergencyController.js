'use strict';

var angular = require('angular');

/**
 * Emergency controller
 */
angular.module('calcentral.controllers').controller('EmergencyController', function(profileFactory, $scope) {
  var loadInformation = function() {
    profileFactory.getPerson().then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
