'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Profile Phone controller
 */
angular.module('calcentral.controllers').controller('ProfilePhoneController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    emptyObject: {
      type: {
        code: ''
      },
      number: '',
      countryCode: '',
      extension: '',
      primary: false
    },
    items: {
      content: [],
      editorEnabled: false
    },
    types: [],
    currentObject: {},
    isSaving: false,
    errorMessage: ''
  });
  $scope.contacts = {};

  var parsePerson = function(data) {
    apiService.profile.parseSection($scope, data, 'phones');
  };

  var parseTypes = function(data) {
    $scope.types = apiService.profile.filterTypes(_.get(data, 'data.feed.xlatvalues.values'), $scope.items);
  };

  var getPerson = profileFactory.getPerson;
  var getTypes = profileFactory.getTypesPhone;

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
    return apiService.profile.delete($scope, profileFactory.deletePhone, {
      type: item.type.code
    }).then(deleteCompleted);
  };

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    actionCompleted(data);
  };

  $scope.save = function(item) {
    apiService.profile.save($scope, profileFactory.postPhone, {
      type: item.type.code,
      phone: item.number,
      countryCode: item.countryCode,
      extension: item.extension,
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
