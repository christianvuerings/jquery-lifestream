'use strict';

var angular = require('angular');

/**
 * Demographic veteran status controller
 */
angular.module('calcentral.controllers').controller('DemographicVeteranController', function(profileFactory, $scope, $q) {
  var parsePerson = function(data) {
    var person = data.data.feed.student;
    angular.extend($scope, {
      veteranStatus: {
        content: person.usaCountry.militaryStatus
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
