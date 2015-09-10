'use strict';

var angular = require('angular');

/**
 * SIR Factory
 */
angular.module('calcentral.factories').factory('sirFactory', function(apiService) {
  var urlChecklist = '/api/campus_solutions/checklist';
  var urlSirConfig = '/api/campus_solutions/sir_config';

  var getChecklist = function(options) {
    return apiService.http.request(options, urlChecklist);
  };
  var getSirConfig = function(options) {
    return apiService.http.request(options, urlSirConfig);
  };

  return {
    getChecklist: getChecklist,
    getSirConfig: getSirConfig
  };
});
