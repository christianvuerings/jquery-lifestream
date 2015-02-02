(function(angular) {
  'use strict';

  /**
   * Up Next Factory
   */
  angular.module('calcentral.factories').factory('upNextFactory', function(apiService) {
    var url = '/api/my/up_next';

    var getUpNext = function(options) {
      return apiService.http.request(options, url);
    };

    return {
      getUpNext: getUpNext
    };
  });
}(window.angular));
