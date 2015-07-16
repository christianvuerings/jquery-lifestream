'use strict';

var angular = require('angular');

/**
 * UID Error controller
 */
angular.module('calcentral.controllers').controller('uidErrorController', function(apiService) {
  apiService.util.setTitle('Unrecognized Log-in');
});
