'use strict';

var angular = require('angular');

/**
 * Webcast Factory
 */
angular.module('calcentral.factories').factory('webcastFactory', function(apiService) {
  var getWebcasts = function(options) {
    return apiService.http.request(options);
  };

  return {
    getWebcasts: getWebcasts
  };
});
