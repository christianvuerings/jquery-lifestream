/**
 * Set the security configuration for CalCentral
 */
(function(angular) {
  'use strict';

  // Set the configuration
  angular.module('calcentral.config').config(function(calcentralConfig, $httpProvider) {
    var token = calcentralConfig.csrfToken;
    // Setting up CSRF tokens for POST, PUT and DELETE requests
    if (token) {
      $httpProvider.defaults.headers.post['X-CSRF-Token'] = token;
      $httpProvider.defaults.headers.put['X-CSRF-Token'] = token;
    }
  });
})(window.angular);
