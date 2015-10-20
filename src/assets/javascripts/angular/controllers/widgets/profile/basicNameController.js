'use strict';

var angular = require('angular');

/**
 * Name Controller
 */
angular.module('calcentral.controllers').controller('BasicNameController', function(apiService, profileFactory, $scope, $q) {
  var parsePerson = function(data) {
    var person = data.data.feed.student;
    var name = apiService.profile.findPrimary(person.names);
    angular.extend($scope, {
      name: {
        content: name
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
