(function(angular) {

  'use strict';

  /**
   * Academics Factory - get data from the academics API
   * @param {Object} apiService CalCentral API service
   */
  angular.module('calcentral.factories').factory('academicsFactory', function(apiService) {

    var url = '/api/my/academics';
    // var url = '/dummy/json/academics.json';

    var getAcademics = function(options) {
      return apiService.http.request(options, url);
    };

    return {
      getAcademics: getAcademics
    };

  });

}(window.angular));
