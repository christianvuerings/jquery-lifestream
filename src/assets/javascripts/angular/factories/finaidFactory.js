'use strict';

var angular = require('angular');

/**
 * Financial Aid Factory
 */
angular.module('calcentral.factories').factory('finaidFactory', function(apiService) {
  // TODO think whether it's optimal for these to be part of the same feed, or not.
  // var urlAward = '/dummy/json/finaid_award.json';
  var urlAward = '/api/my/finaid';
  // var urlBudget = '/dummy/json/finaid_budget.json';
  var urlBudget = urlAward;

  var urlFinaidYear = '/dummy/json/finaid_year.json';

  var urlSummary = '/api/campus_solutions/aid_years';
  // var urlSummary = '/dummy/json/finaid_summary.json';

  var getBudget = function(options) {
    return apiService.http.request(options, urlBudget);
  };

  var getAwards = function(options) {
    return apiService.http.request(options, urlAward);
  };

  var getFinaidYearInfo = function(options) {
    // TODO - update with real API
    return apiService.http.request(options, urlFinaidYear + '?finaidYear=' + options.finaidYear);
  };

  var getSummary = function(options) {
    return apiService.http.request(options, urlSummary);
  };

  return {
    getAwards: getAwards,
    getBudget: getBudget,
    getFinaidYearInfo: getFinaidYearInfo,
    getSummary: getSummary
  };
});
