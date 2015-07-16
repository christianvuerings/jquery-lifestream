'use strict';

var angular = require('angular');

/**
 * Error controller
 */
angular.module('calcentral.controllers').controller('ErrorController', function(apiService) {
  apiService.util.setTitle('Error');
});
