/**
 * Set the HTTP Error configuration for CalCentral
 */
(function(calcentral) {

  'use strict';

  // Set the configuration
  calcentral.config(['$httpProvider', function($httpProvider) {

    // Add the http error inceptorservice to the list of response inceptors
    $httpProvider.responseInterceptors.push('httpErrorInterceptorService');

    // Add the http spinner servive to the list of response inceptors
    $httpProvider.responseInterceptors.push('spinnerInterceptorService');

  }]);

})(window.calcentral);
