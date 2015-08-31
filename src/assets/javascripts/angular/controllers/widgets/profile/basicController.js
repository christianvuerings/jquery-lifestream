'use strict';

var angular = require('angular');

/**
 * Basic profile controller
 */
angular.module('calcentral.controllers').controller('BasicController', function(profileFactory, $scope) {
  var loadContactInformation = function() {
    profileFactory.getPerson().then(function() {
      $scope.isLoading = false;
    });
  };

  loadContactInformation();
});
