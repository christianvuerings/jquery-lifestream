'use strict';

var angular = require('angular');

/**
 * Profile Address controller
 */
angular.module('calcentral.controllers').controller('ProfileAddressController', function(profileFactory, $scope, $q) {
  angular.extend($scope, {
    addresses: {
      content: [],
      editorEnabled: false
    },
    currentEditObject: {}
  });

  var getPerson = profileFactory.getPerson().then(function(data) {
    var person = data.data.feed.person;
    angular.extend($scope, {
      addresses: {
        content: person.addresses.address
      }
    });
  });

  var loadInformation = function() {
    $q.all(getPerson).then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
