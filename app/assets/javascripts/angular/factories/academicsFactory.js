(function(angular) {
  'use strict';

  /**
   * Academics Factory
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
