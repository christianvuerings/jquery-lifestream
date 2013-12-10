(function(angular) {

  'use strict';

  angular.module('calcentral.services').factory('httpErrorInterceptorService', function($q, errorService) {

    return {

      // Basic idea from http://stackoverflow.com/questions/11971213

      /**
       * Success function, will happen when the request was successful
       * @param {Object} response JSON object containing response params
       */
      response: function(response) {
        return response;
      },

      /**
       * Error function, will happen when we get a 4xx or 5xx exception
       * @param {Object} response JSON object containing response params
       */
      responseError: function(response) {
        var status = response.status;

        if (status >= 400) {
          errorService.send('httpErrorInterceptorService - ' + response.status + ' - ' + response.config.url);
        }
        // otherwise
        return $q.reject(response);
      }

    };

  });

}(window.angular));
