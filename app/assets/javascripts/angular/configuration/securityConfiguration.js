/**
 * Set the security configuration for CalCentral
 */
(function(angular, document) {

  'use strict';

  // Set the configuration
  angular.module('calcentral.config').config(function($httpProvider) {

    // Setting up CSRF tokens for POST, PUT and DELETE requests
    var tokenElement = document.querySelector('meta[name=csrf-token]');
    if (tokenElement && tokenElement.content) {
      $httpProvider.defaults.headers.post['X-CSRF-Token'] = tokenElement.content;
      $httpProvider.defaults.headers.put['X-CSRF-Token'] = tokenElement.content;
    }

  });

})(window.angular, window.document);
