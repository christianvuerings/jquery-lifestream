'use strict';

var angular = require('angular');

/**
 * Set the HTTP Error configuration for CalCentral
 */
angular.module('calcentral.config').config(function($httpProvider) {
  // Add the HTTP error service
  $httpProvider.interceptors.push('httpErrorInterceptorService');

  // Add the spinner service
  $httpProvider.interceptors.push('spinnerInterceptorService');
});
