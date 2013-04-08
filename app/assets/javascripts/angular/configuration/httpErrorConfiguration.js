/**
 * Set the HTTP Error configuration for CalCentral
 */
(function(calcentral) {

  'use strict';

  // Set the configuration
  calcentral.config(['$httpProvider', function($httpProvider) {

    // Add the http inceptorservice to the list of response inceptors
    $httpProvider.responseInterceptors.push('httpInterceptorService');

  }]);

})(window.calcentral);
