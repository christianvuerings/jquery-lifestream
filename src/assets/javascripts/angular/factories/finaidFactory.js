(function(angular) {
  'use strict';

  /**
   * Financial Aid Factory
   */
  angular.module('calcentral.factories').factory('finaidFactory', function(apiService) {
    var urlAward = '/dummy/json/finaid_award.json';
    var urlBudget = '/dummy/json/finaid_budget.json';

    var getBudget = function(options) {
      return apiService.http.request(options, urlBudget);
    };

    var getAwards = function(options) {
      return apiService.http.request(options, urlAward);
    };

    return {
      getBudget: getBudget,
      getAwards: getAwards
    };
  });
}(window.angular));
