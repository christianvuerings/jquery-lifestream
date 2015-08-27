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
    var person = data.data.feed.person;
    angular.extend($scope, {
      phones: {
        content: person.phones
      }
    });
  };

  var parsePhoneTypes = function(data) {
    if (!_.get(data, 'data.feed.xlatvalues.values')) {
      return;
    }
    $scope.phoneTypes = _.filter(data.data.feed.xlatvalues.values, function(value) {
      // Filter out the different type controls
      // D = Display Only
      // F = Full Edit
      // N = Do Not Display
      // U = Edit - No Delete
      return value.typeControl !== 'N';
    });
  };

  var getPerson = profileFactory.getPerson().then(parsePerson);
  var getPhoneTypes = profileFactory.getPhoneTypes().then(parsePhoneTypes);

  var loadInformation = function() {
    $q.all(getPerson, getPhoneTypes).then(function() {
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

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    if (data.data.errored) {
      $scope.errorMessage = data.data.feed.errmsgtext;
    } else {
      $scope.closeEditor();
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
