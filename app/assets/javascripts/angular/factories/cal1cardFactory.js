(function(angular) {

  'use strict';

  /**
   * Cal1Card Factory - get data from the cal1card API
   * @param {Object} apiService CalCentral API Service
   */
  angular.module('calcentral.factories').factory('cal1CardFactory', function(apiService) {

    var url = '/api/my/cal1card';
    // var url = '/dummy/json/cal1card.json';

    var getCal1Card = function(options) {
      return apiService.http.request(options, url);
    };

    return {
      getCal1Card: getCal1Card
    };

  });

}(window.angular));
