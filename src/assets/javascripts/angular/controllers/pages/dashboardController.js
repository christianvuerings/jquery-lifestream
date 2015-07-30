'use strict';

var angular = require('angular');

/**
 * Dashboard controller
 */
angular.module('calcentral.controllers').controller('DashboardController', function(apiService) {
  apiService.util.setTitle('Dashboard');
});
