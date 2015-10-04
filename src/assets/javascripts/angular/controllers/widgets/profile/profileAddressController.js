'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Profile Address controller
 */
angular.module('calcentral.controllers').controller('ProfileAddressController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    emptyObject: {
      type: {
        code: ''
      },
      countryCode: 'USA'
    },
    items: {
      content: [],
      editorEnabled: false
    },
    countries: [],
    types: [],
    currentObject: {},
    isSaving: false,
    errorMessage: ''
  });

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
    $scope.countries = _.get(data, 'data.feed.countries');
  };

  var parseAddressFields = function(data) {
    $scope.currentObject.fields = _.get(data, 'data.feed.labels');
  };

  var getAddressFields = function(countryCode) {
    if (!countryCode) {
      return;
    }
    profileFactory.getAddressFields({
      country: countryCode
    }).then(parseAddressFields);
  };

  /**
   * We need to watch when the country changes, if so, load the address fields dynamically depending on the country
   */
  var startCountryWatch = function() {
    $scope.$watch('currentObject.countryCode', getAddressFields);
  };

  var getPerson = profileFactory.getPerson;
  var getTypes = profileFactory.getTypesAddress;
  var getCountries = profileFactory.getCountries;

  var loadInformation = function(options) {
    $scope.isLoading = true;
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

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope);
  };

  loadInformation();
});
