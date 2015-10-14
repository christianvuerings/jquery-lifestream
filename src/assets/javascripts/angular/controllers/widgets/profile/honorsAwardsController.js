'use strict';

var angular = require('angular');

/**
 * Honors & Awards controller
 */
angular.module('calcentral.controllers').controller('HonorsAwardsController', function(profileFactory, $scope) {
  var loadInformation = function() {
    profileFactory.getPerson().then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
