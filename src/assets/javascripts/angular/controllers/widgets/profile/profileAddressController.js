'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Profile Address controller
 */
angular.module('calcentral.controllers').controller('ProfileAddressController', function(apiService, profileFactory, $scope) {
  var initialState = {
    countries: [],
    currentObject: {},
    emptyObject: {
      type: {
        code: ''
      },
      country: 'USA',
      fields: {}
    },
    errorMessage: '',
    isSaving: false,
    items: {
      content: [],
      editorEnabled: false
    },
    states: [],
    types: []
  };

  angular.extend($scope, initialState);
  var initialEdit = {
    state: '',
    load: false
  };
  var countryWatcher;

  /**
   * We need to replace the \n with <br /> in the formattedAddresses
   */
  var fixFormattedAddresses = function() {
    $scope.items.content = $scope.items.content.map(function(element) {
      element.formattedAddress = element.formattedAddress.replace(/\\n/g, '<br />');
      return element;
    });
  };

  var parsePerson = function(data) {
    apiService.profile.parseSection($scope, data, 'addresses');
    fixFormattedAddresses();
  };

  var parseTypes = function(data) {
    $scope.types = apiService.profile.filterTypes(_.get(data, 'data.feed.addressTypes'), $scope.items);
  };

  var parseCountries = function(data) {
    $scope.countries = _.sortBy(_.filter(_.get(data, 'data.feed.countries'), {
      hasAddressFields: true
    }), 'descr');
  };

  var parseAddressFields = function(data) {
    $scope.currentObject.fields = _.get(data, 'data.feed.labels');
  };

  var parseStates = function(data) {
    $scope.states = _.sortBy(_.get(data, 'data.feed.states'), 'descr');
    if ($scope.states && $scope.states.length) {
      angular.merge($scope.currentObject, {
        data: {
          state: initialEdit.state || $scope.states[0].state
        }
      });
      initialEdit.state = '';
    }
  };

  /**
   * Removes previous address data, we need to do this every time you change the country
   */
  var removePreviousAddressData = function() {
    $scope.currentObject.data = _.object(_.map($scope.currentObject.data, function(value, key) {
      if (['country', 'type'].indexOf(key) === -1) {
        return [key, ''];
      } else {
        return [key, value];
      }
    }));
  };

  var countryWatch = function(countryCode) {
    if (!countryCode) {
      return;
    }
    if (!initialEdit.load) {
      removePreviousAddressData();
    }
    $scope.currentObject.stateFieldLoading = true;
    initialEdit.load = false;
    // $scope.currentObject.data = {};
    // Get the different address fields / labels for the country
    profileFactory.getAddressFields({
      country: countryCode
    })
    .then(parseAddressFields)
    // Get the states for a certain country (if available)
    .then(function() {
      return profileFactory.getStates({
        country: countryCode
      });
    })
    .then(parseStates)
    .then(function() {
      $scope.currentObject.stateFieldLoading = false;
    });
  };

  /**
   * We need to watch when the country changes, if so, load the address fields dynamically depending on the country
   */
  var startCountryWatch = function() {
    countryWatcher = $scope.$watch('currentObject.data.country', countryWatch);
  };

  var getPerson = profileFactory.getPerson;
  var getTypes = profileFactory.getTypesAddress;
  var getCountries = profileFactory.getCountries;

  var loadInformation = function(options) {
    $scope.isLoading = true;

    // If we were previously watching, we need to remove that
    if (countryWatcher) {
      countryWatcher();
    }

    getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(getTypes)
    .then(parseTypes)
    .then(getCountries)
    .then(parseCountries)
    .then(startCountryWatch)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var actionCompleted = function(data) {
    angular.extend($scope, initialState);
    apiService.profile.actionCompleted($scope, data, loadInformation);
  };

  var deleteCompleted = function(data) {
    $scope.isDeleting = false;
    actionCompleted(data);
  };

  $scope.delete = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteAddress, {
      type: item.type.code
    }).then(deleteCompleted);
  };

  var saveCompleted = function(data) {
    $scope.isSaving = false;
    actionCompleted(data);
  };

  /**
   * We need to map the address fields for the current country and the ones (depending on country) that the user has entered
   */
  var matchFields = function(fields, item) {
    var fieldIds = _.pluck(fields, 'field');
    var returnObject = {};
    _.forEach(item, function(value, key) {
      if (_.contains(fieldIds, key)) {
        returnObject[key] = value;
      }
    });
    return returnObject;
  };

  $scope.save = function(item) {
    var merge = _.merge({
      addressType: item.type.code,
      country: item.country
    }, matchFields($scope.currentObject.fields, item));

    apiService.profile
      .save($scope, profileFactory.postAddress, merge)
      .then(saveCompleted);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope, $scope.emptyObject);
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
    $scope.currentObject.data.country = item.country;
    initialEdit.state = item.state || '';
    initialEdit.load = true;
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  loadInformation();
});
