'use strict';

var angular = require('angular');

/**
 * My Finances controller
 */
angular.module('calcentral.controllers').controller('MyFinancesController', function(apiService) {
  apiService.util.setTitle('My Finances');
});
