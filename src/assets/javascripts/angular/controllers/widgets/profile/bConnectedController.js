'use strict';

var angular = require('angular');

/**
 * bConnected controller
 */
angular.module('calcentral.controllers').controller('bConnectedController', function(apiService, $scope) {
  var services = ['Google'];

  var refreshIsCalendarOptedIn = function(profile) {
    $scope.settings = {
      isCalendarOptedIn: profile.isCalendarOptedIn
    };
  };

  var refreshServices = function(profile) {
    $scope.connectedServices = services.filter(function(element) {
      return profile['has' + element + 'AccessToken'];
    });
    $scope.disConnectedServices = services.filter(function(element) {
      return !profile['has' + element + 'AccessToken'];
    });
  };

  $scope.$on('calcentral.api.user.profile', function(event, profile) {
    if (profile) {
      refreshIsCalendarOptedIn(profile);
      refreshServices(profile);
    }
  });

  $scope.api.user.fetch({
    refreshCache: true
  });

  if (apiService.user.profile) {
    refreshServices(apiService.user.profile);
  }
});
