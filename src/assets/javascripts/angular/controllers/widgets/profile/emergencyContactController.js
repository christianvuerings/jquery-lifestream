'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Emergency Contact controller
 */
angular.module('calcentral.controllers').controller('EmergencyContactController', function(apiService, profileFactory, $scope, $q) {
  /**
   * Fix the formatted addresseses (if there are any)
   */
  var fixFormattedAddresses = function() {
    $scope.items.content = $scope.items.content.map(function(element) {
      var formattedAddress = _.get(element, 'address.formattedAddress');
      if (formattedAddress) {
        element.address.formattedAddress = apiService.profile.fixFormattedAddress(formattedAddress);
      }
      return element;
    });
  };

  var parsePerson = function(data) {
    apiService.profile.parseSection($scope, data, 'emergencyContacts');
    fixFormattedAddresses();
  };

  var getPerson = profileFactory.getPerson().then(parsePerson);

  var loadInformation = function() {
    $q.all(getPerson).then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
