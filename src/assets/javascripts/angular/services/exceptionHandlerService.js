'use strict';

var angular = require('angular');

angular.module('calcentral.services').factory('$exceptionHandler', function($log, errorService) {
  // Return the function
  return function(exception) {
    // Output to the angular log
    // This is the standard angular behavior
    $log.error.apply($log, arguments);

    // Also log the exception to our JS error logging system
    errorService.send(exception);
  };
});
