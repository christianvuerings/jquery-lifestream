'use strict';

var angular = require('angular');

/**
 * Basic profile controller
 */
angular.module('calcentral.controllers').controller('BasicController', function(profileFactory, $scope) {
  var loadInformation = function() {
    profileFactory.getPerson().then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
