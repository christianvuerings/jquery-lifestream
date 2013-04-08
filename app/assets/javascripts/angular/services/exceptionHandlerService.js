(function(angular) {

  'use strict';

  angular.module('calcentral.services').factory('$exceptionHandler', ['$log', 'errorService', function($log, errorService) {

    // Return the function
    return function(exception, cause) {

      // Output to the angular log
      // This is the standard angular behavior
      $log.error.apply($log, arguments);

      // Also log the exception to our JS error logging system
      errorService.send(exception);
    };

  }]);

}(window.angular));
