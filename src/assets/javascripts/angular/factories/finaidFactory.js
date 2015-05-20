(function(angular) {
  'use strict';

  /**
   * Financial Aid Factory
   */
  angular.module('calcentral.factories').factory('finaidFactory', function(apiService) {
    // TODO think whether it's optimal for these to be part of the same feed, or not.
    var urlAward = '/api/my/finaid';
    var urlBudget = urlAward;

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
