'use strict';

var angular = require('angular');

/**
 * Financial Aid Factory
 */
angular.module('calcentral.factories').factory('finaidFactory', function(apiService, $http) {
  // TODO think whether it's optimal for these to be part of the same feed, or not.
  // var urlAward = '/dummy/json/finaid_award.json';
  var urlAward = '/api/my/finaid';
  // var urlBudget = '/dummy/json/finaid_budget.json';
  var urlBudget = urlAward;

  var urlFinaidYear = '/api/campus_solutions/financial_aid_data';
  // var urlFinaidYear = '/dummy/json/financial_aid_data.json';

  var urlSummary = '/api/campus_solutions/aid_years';
  // var urlSummary = '/dummy/json/finaid_summary.json';

  var urlPostTC = '/api/campus_solutions/terms_and_conditions';
  var urlPostT4 = '/api/campus_solutions/title4';

  var getBudget = function(options) {
    return apiService.http.request(options, urlBudget);
  };

  var getAwards = function(options) {
    return apiService.http.request(options, urlAward);
  };

  var getFinaidYearInfo = function(options) {
    // TODO - update with real API
    return apiService.http.request(options, urlFinaidYear + '?aid_year=' + options.finaidYearId);
  };

  var getSummary = function(options) {
    return apiService.http.request(options, urlSummary);
  };

  var postTCResponse = function(finaidYearId, response) {
    return $http.post(urlPostTC, {
      aidYear: finaidYearId,
      response: response
    });
  };

  var postT4Response = function(response) {
    return $http.post(urlPostT4, {
      response: response
    });
  };

  return {
    getAwards: getAwards,
    getBudget: getBudget,
    getFinaidYearInfo: getFinaidYearInfo,
    getSummary: getSummary,
    postTCResponse: postTCResponse,
    postT4Response: postT4Response
  };
});
