'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Profile Phone controller
 */
angular.module('calcentral.controllers').controller('ProfilePhoneController', function(profileFactory, $scope, $q) {
  angular.extend($scope, {
    phones: {
      content: [],
      editorEnabled: false
    },
    phoneTypes: [],
    currentObject: {},
    isSaving: false,
    errorMessage: ''
  });
  $scope.contacts = {};

  var emptyObject = {
    type: {
      code: ''
    },
    number: '',
    countryCode: '',
    extension: '',
    primary: false
  };

  var parsePerson = function(data) {
    var person = data.data.feed.student;
    angular.extend($scope, {
      phones: {
        content: person.phones
      }
    });
  };

  /**
   * Parse the phone types
   * We should only return the items that aren't yet in the person object
   */
  var parsePhoneTypes = function(data) {
    if (!_.get(data, 'data.feed.xlatvalues.values')) {
      return;
    }

    // Current types for the person
    var currentTypes = _.pluck($scope.phones.content, 'type.code');

    // Different type controls for the types:
    // D = Display Only
    // F = Full Edit
    // N = Do Not Display
    // U = Edit - No Delete
    $scope.phoneTypes = _.filter(data.data.feed.xlatvalues.values, function(value) {
      return currentTypes.indexOf(value.fieldvalue) === -1 && value.typeControl !== 'D';
    });
  };

  var getPerson = profileFactory.getPerson;
  var getPhoneTypes = profileFactory.getPhoneTypes;

  var loadInformation = function(options) {
    $scope.isLoading = true;
    getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(getPhoneTypes)
    .then(parsePhoneTypes)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var closeEditors = function(broadcast) {
    if (broadcast) {
      $scope.$broadcast('calcentral.custom.api.profile.closeEditors');
    }
    angular.forEach($scope.phones.content, function(item) {
      item.isModifying = false;
    });
  };

  $scope.deletePhone = function(phone) {
    profileFactory.deletePhone({
      data: {
        type: phone.type.code
      }
    });
  };

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    if (data.data.errored) {
      $scope.errorMessage = data.data.feed.errmsgtext;
    } else {
      $scope.closeEditor();
      loadInformation({
        refresh: true
      });
    }
  };

  $scope.savePhone = function(phone) {
    $scope.isSaving = true;

    profileFactory.postPhone({
      type: phone.type.code,
      phone: phone.number,
      countryCode: phone.countryCode,
      extension: phone.extension,
      isPreferred: phone.primary ? 'Y' : 'N'
    }).then(saveCompleted);
  };

  var showSaveAddPhone = function(phone) {
    closeEditors(true);
    phone.isModifying = true;
    $scope.currentObject = angular.copy(phone);
    $scope.errorMessage = '';
    $scope.phones.editorEnabled = true;
  };

  $scope.showAddPhone = function() {
    emptyObject.isAdding = true;
    // Select the first item in the dropdown
    emptyObject.type.code = $scope.phoneTypes[0].fieldvalue;
    showSaveAddPhone(emptyObject);
  };

  $scope.showEditPhone = function(phone) {
    showSaveAddPhone(phone);
  };

  $scope.closeEditor = function() {
    closeEditors(true);
    $scope.currentObject = {};
    $scope.phones.editorEnabled = false;
  };

  loadInformation();
});
