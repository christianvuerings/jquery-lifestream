(function(angular) {

  'use strict';

  /**
   * Finances Factory - get data from the badges API
   * @param {Object} apiService CalCentral API Service
   */
  angular.module('calcentral.factories').factory('financesFactory', function(apiService) {

    var url = '/api/my/financials';

    var getFinances = function(options) {
      return apiService.http.request(options, url);
    };

    return {
      getFinances: getFinances
    };

  });

}(window.angular));
