(function(angular) {

  'use strict';

  angular.module('calcentral.services').factory('spinnerInterceptorService', function($q) {

    return {

      /**
       * Success function, will happen when the request was successful
       * @param {Object} response JSON object containing response params
       */
      response: function(response) {

        // The data will be a string when it's a template that has been requested.
        if (angular.isObject(response.data)) {
          response.data.is_loading = false;
        }
        return response;
      },

      /**
       * Error function, will happen when we get a 4xx or 5xx exception
       * @param {Object} response JSON object containing response params
       */
      responseError: function(response) {

        // TODO we'll need to change this so we can show a valuable
        // message to the user when an error occurs
        // We can do this as soon as we get good error responses back from the server.
        if (angular.isObject(response.data)) {
          response.data.is_loading = false;
        } else {
          response.data = {
            is_loading: false
          };
        }
        return $q.reject(response);
      }

    };

  });

}(window.angular));
