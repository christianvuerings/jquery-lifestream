/**
 * Set the security configuration for CalCentral
 */
(function(calcentral, document) {

  'use strict';

  // Set the configuration
  calcentral.config(['$httpProvider', function($httpProvider) {

    // Setting up CSRF tokens for POST, PUT and DELETE requests
    var tokenElement = document.querySelector('meta[name=csrf-token]');
    if (tokenElement && tokenElement.content) {
      $httpProvider.defaults.headers.post['X-CSRF-Token'] = tokenElement.content;
      $httpProvider.defaults.headers.put['X-CSRF-Token'] = tokenElement.content;
    }

  }]);

})(window.calcentral, window.document);
