'use strict';

var angular = require('angular');

angular.module('calcentral.services').service('dateService', [function() {
  // Expose methods
  return {
    now: Date.now(),
    moment: require('moment')
  };
}]);
