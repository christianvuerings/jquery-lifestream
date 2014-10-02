(function(angular) {
  'use strict';

  /**
   * My Groups Factory
   */
  angular.module('calcentral.factories').factory('myGroupsFactory', function(apiService) {
    var url = '/api/my/groups';

    var getGroups = function(options) {
      return apiService.http.request(options, url);
    };

    return {
      getGroups: getGroups
    };
  });
}(window.angular));
