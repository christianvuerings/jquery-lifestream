'use strict';

var angular = require('angular');

/**
 * Contact controller
 */
angular.module('calcentral.controllers').controller('ContactController', function(contactFactory, $scope, $q) {
  $scope.contacts = {};

  var loadContactInformation = function() {
    $q.all([
      contactFactory.getEmails()
    ]).then(function(data) {
      for (var i = 0; i < data.length; i++) {
        if (data[i].data && data[i].data.feed) {
          angular.extend($scope.contacts, data[i].data.feed);
        }
      }
      $scope.isLoading = false;
    });
  };

  loadContactInformation();
});
