'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Profile Email controller
 */
angular.module('calcentral.controllers').controller('ProfileEmailController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    currentObject: {},
    emptyObject: {
      type: {
        code: ''
      },
      emailAddress: '',
      primary: false
    },
    items: {
      content: [],
      editorEnabled: false
    },
    types: [],
    isSaving: false,
    errorMessage: ''
  });
  $scope.contacts = {};

  var parsePerson = function(data) {
    apiService.profile.parseSection($scope, data, 'emails');
  };

  var parseTypes = function(data) {
    $scope.types = apiService.profile.filterTypes(_.get(data, 'data.feed.xlatvalues.values'), $scope.items);
  };

  var getPerson = profileFactory.getPerson;
  var getTypes = profileFactory.getTypesEmail;

  var loadInformation = function(options) {
    $scope.isLoading = true;
    getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(getTypes)
    .then(parseTypes)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var actionCompleted = function(data) {
    apiService.profile.actionCompleted($scope, data, loadInformation);
  };

  var deleteCompleted = function(data) {
    $scope.isDeleting = false;
    actionCompleted(data);
  };

  $scope.delete = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteEmail, {
      type: item.type.code
    }).then(deleteCompleted);
  };

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    actionCompleted(data);
  };

  $scope.save = function(item) {
    apiService.profile.save($scope, profileFactory.postEmail, {
      type: item.type.code,
      email: item.emailAddress,
      isPreferred: item.primary ? 'Y' : 'N'
    }).then(saveCompleted);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope);
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  loadInformation();
});
