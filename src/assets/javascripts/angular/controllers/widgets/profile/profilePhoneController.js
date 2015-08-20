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
    currentEditObject: {}
  });

  var loadInformation = function() {
    profileFactory.getPerson().then(function(data) {
      var person = data.data.feed.person;
      angular.extend($scope, {
        phones: {
          content: person.phones.phone
        }
      });
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
