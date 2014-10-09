/**
 * Set the HTTP Error configuration for CalCentral
 */
(function(angular) {
  'use strict';

  // Set the configuration
  angular.module('calcentral.config').config(function($httpProvider) {
    // Add the HTTP error service
    $httpProvider.interceptors.push('httpErrorInterceptorService');

    // Add the spinner service
    $httpProvider.interceptors.push('spinnerInterceptorService');
  });
})(window.angular);
