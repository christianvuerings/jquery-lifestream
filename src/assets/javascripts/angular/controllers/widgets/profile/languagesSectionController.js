'use strict';

var angular = require('angular');

/**
 * Language section controller
 */
angular.module('calcentral.controllers').controller('LanguagesSectionController', function(profileFactory, $scope, $q) {
  var parsePerson = function(data) {
    var person = data.data.feed.student;
    angular.extend($scope, {
      languages: {
        content: person.languages
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
