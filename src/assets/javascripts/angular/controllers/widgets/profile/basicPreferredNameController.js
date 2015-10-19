'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Preferred Name Controller
 */
angular.module('calcentral.controllers').controller('BasicPreferredNameController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    emptyObject: {},
    items: {
      content: [],
      editorEnabled: false
    },
    types: [],
    currentObject: {},
    isSaving: false,
    errorMessage: '',
    primary: {}
  });

  var parsePerson = function(data) {
    var person = data.data.feed.student;
    var preferredName = apiService.profile.findPreferred(person.names);
    $scope.primary = apiService.profile.findPrimary(person.names);
    angular.extend($scope, {
      items: {
        content: [preferredName]
      }
    });
  };

  var getPerson = profileFactory.getPerson;

  var loadInformation = function(options) {
    $scope.isLoading = true;
    getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var actionCompleted = function(data) {
    apiService.profile.actionCompleted($scope, data, loadInformation);
  };

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    actionCompleted(data);
  };

  $scope.save = function(item) {
    apiService.profile.save($scope, profileFactory.postName, {
      type: 'PRF',
      firstName: item.givenName,
      middleName: item.middleName,
      lastName: item.familyName,
      suffix: item.suffixName
    }).then(saveCompleted);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope, {
      givenName: $scope.primary.givenName,
      middleName: $scope.primary.middleName,
      familyName: $scope.primary.familyName,
      suffixName: $scope.primary.suffixName
    });
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  loadInformation();
});
