'use strict';

var angular = require('angular');

/**
 * Profile Phone controller
 */
angular.module('calcentral.controllers').controller('ProfilePhoneController', function(profileFactory, $scope) {
  angular.extend($scope, {
    phones: {
      content: [],
      editorEnabled: false
    },
    currentObject: {}
  });

  var loadInformation = function() {
    profileFactory.getPerson().then(function(data) {
      var person = data.data.feed.person;
      angular.extend($scope, {
        phones: {
          content: person.phones
        }
      });
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
