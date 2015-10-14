'use strict';

var angular = require('angular');

/**
 * Languages controller
 */
angular.module('calcentral.controllers').controller('LanguagesController', function(profileFactory, $scope) {
  var loadInformation = function() {
    profileFactory.getPerson().then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
