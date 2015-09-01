'use strict';

var angular = require('angular');

/**
 * Emergency Contact controller
 */
angular.module('calcentral.controllers').controller('EmergencyContactController', function(profileFactory, $scope, $q) {
  var parsePerson = function(data) {
    var person = data.data.feed.person;
    angular.extend($scope, {
      emergencyContacts: {
        content: person.emergencyContacts
      }
    });
  };

  var getPerson = profileFactory.getPerson().then(parsePerson);

  var loadInformation = function() {
    $q.all(getPerson).then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
