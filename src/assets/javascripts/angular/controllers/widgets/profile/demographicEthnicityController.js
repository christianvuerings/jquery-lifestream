'use strict';

var angular = require('angular');

/**
 * Demographic gender controller
 */
angular.module('calcentral.controllers').controller('DemographicEthnicityController', function(profileFactory, $scope, $q) {
  var parsePerson = function(data) {
    var person = data.data.feed.person;
    angular.extend($scope, {
      ethnicities: {
        content: person.ethnicities
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
