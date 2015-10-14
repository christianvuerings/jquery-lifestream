'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Name Controller
 */
angular.module('calcentral.controllers').controller('BasicNameController', function(profileFactory, $scope, $q) {
  var findPrimary = function(names) {
    return _.find(names, function(name) {
      return name.type.code === 'PRI';
    });
  };

  var parsePerson = function(data) {
    var person = data.data.feed.student;
    var name = findPrimary(person.names);
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
