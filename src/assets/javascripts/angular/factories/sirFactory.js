'use strict';

var angular = require('angular');

/**
 * SIR Factory
 */
angular.module('calcentral.factories').factory('sirFactory', function(apiService, $http) {
  var urlChecklist = '/api/campus_solutions/checklist';
  var urlSirConfig = '/api/campus_solutions/sir_config';
  var urlSirResponse = '/api/campus_solutions/sir_response';

  var getChecklist = function(options) {
    return apiService.http.request(options, urlChecklist);
  };
  var getSirConfig = function(options) {
    return apiService.http.request(options, urlSirConfig);
  };

  var postSirResponse = function(response) {
    return $http.post(urlSirResponse, {
      response: response
    });
  };

  return {
    getChecklist: getChecklist,
    getSirConfig: getSirConfig,
    postSirResponse: postSirResponse
  };
});
