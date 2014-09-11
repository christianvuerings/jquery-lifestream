(function(angular) {

  'use strict';

  /**
   * Academics Factory - get data from the academics API
   * @param {Object} apiService CalCentral API service
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('academicsFactory', function(apiService, $http) {

    var url = '/api/my/academics';

    var getAcademics = function(options) {
      // return $http.get('/dummy/json/academics.json');
      apiService.util.clearCache(options, url);
      return $http.get(url, {
        cache: true
      });
    };

    return {
      getAcademics: getAcademics
    };

  });

}(window.angular));
