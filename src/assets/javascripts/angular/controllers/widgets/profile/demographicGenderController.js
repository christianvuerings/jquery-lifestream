'use strict';

var angular = require('angular');

/**
 * Demographic gender controller
 */
angular.module('calcentral.controllers').controller('DemographicGenderController', function(profileFactory, $scope, $q) {
  var parsePerson = function(data) {
    var person = data.data.feed.student;
    angular.extend($scope, {
      gender: {
        content: person.gender
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
