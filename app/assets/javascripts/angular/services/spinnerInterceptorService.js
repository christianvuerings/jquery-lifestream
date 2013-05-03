(function(angular) {

  'use strict';

  angular.module('calcentral.services').factory('spinnerInterceptorService', ['$q' , function($q) {

    /**
     * Success function, will happen when the request was successful
     * @param {Object} response JSON object containing response params
     */
    var success = function(response) {

      // The data will be a string when it's a template that has been requested.
      if (angular.isObject(response.data)) {
        response.data._is_loading = false;
      }
      return response;
    };

    /**
     * Error function, will happen when we get a 4xx or 5xx exception
     * @param {Object} response JSON object containing response params
     */
    var error = function(response) {

      // TODO we'll need to change this so we can show a valuable
      // message to the user when an error occurs
      // We can do this as soon as we get good error responses back from the server.
      if (angular.isObject(response.data)) {
        response.data._is_loading = false;
      }
      return $q.reject(response);

    };

    // Return the function
    return function(promise) {
      return promise.then(success, error);
    };

  }]);

}(window.angular));
