(function(angular) {
  'use strict';

  /**
   * Blog Factory
   */
  angular.module('calcentral.factories').factory('blogFactory', function(apiService) {
    var url = '/api/blog';

    var getBlog = function(options) {
      return apiService.http.request(options, url);
    };

    return {
      getBlog: getBlog
    };
  });
}(window.angular));
