'use strict';

var angular = require('angular');

/**
 * Honors & awards section controller
 */
angular.module('calcentral.controllers').controller('HonorsAwardsSectionController', function(profileFactory, $scope, $q) {
  var parseAwardHonors = function(awardHonors) {
    var copy = angular.copy(awardHonors);
    for (var i = 0; i < copy.length; i++) {
      // We need to parse the returned date (2015-12-20) to a JavaScript date
      copy[i].awardDate = Date.parse(copy[i].awardDate);
    }
    return copy;
  };

  var parsePerson = function(data) {
    var person = data.data.feed.student;
    angular.extend($scope, {
      awardHonors: {
        content: parseAwardHonors(person.awardHonors)
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
