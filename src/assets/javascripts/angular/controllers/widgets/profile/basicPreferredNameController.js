'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Name Controller
 */
angular.module('calcentral.controllers').controller('BasicPreferredNameController', function(profileFactory, $scope, $q) {
  var findPreferred = function(names) {
    return _.find(names, function(name) {
      return name.type.code === 'PRF';
    });
  };

  var parsePerson = function(data) {
    var person = data.data.feed.student;
    var preferredName = findPreferred(person.names);
    angular.extend($scope, {
      preferredName: {
        content: preferredName
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
