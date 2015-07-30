'use strict';

var angular = require('angular');

/**
 * API Test Factory
 */
angular.module('calcentral.factories').factory('apiTestFactory', function(apiService) {
  var smokeTestUrl = '/api/smoke_test_routes';

  var smokeTest = function(options) {
    return apiService.http.request(options, smokeTestUrl);
  };

  var request = function(options) {
    return apiService.http.request(options);
  };

  return {
    smokeTest: smokeTest,
    request: request
  };
});
