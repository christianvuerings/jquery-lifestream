(function(angular) {

  'use strict';

  angular.module('calcentral.services').factory('httpInterceptorService', ['$q' , 'errorService', function($q, errorService) {

    // Basic idea from http://stackoverflow.com/questions/11971213

    /**
     * Success function, will happen when the request was successful
     * @param {Object} response JSON object containing response params
     */
    var success = function(response) {
      return response;
    };

    /**
     * Error function, will happen when we get a 4xx or 5xx exception
     * @param {Object} response JSON object containing response params
     */
    var error = function(response) {
      var status = response.status;

      if (status >= 400) {
        errorService.send('httpInterceptorService - ' + response.status + ' - ' + response.config.url);
        return;
      }
      // otherwise
      return $q.reject(response);

    };

    // Return the function
    return function(promise) {
      return promise.then(success, error);
    };

  }]);

}(window.angular));
