'use strict';

var angular = require('angular');

/**
 * Contact controller
 */
angular.module('calcentral.controllers').controller('ContactController', function(profileFactory, $scope) {
  var loadInformation = function() {
    profileFactory.getPerson().then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
