(function(angular) {
  'use strict';

  /**
   * Badges Factory
   */
  angular.module('calcentral.factories').factory('badgesFactory', function(apiService) {
    var url = '/api/my/badges';

    var getBadges = function(options) {
      return apiService.http.request(options, url);
    };

    return {
      getBadges: getBadges
    };
  });
}(window.angular));
