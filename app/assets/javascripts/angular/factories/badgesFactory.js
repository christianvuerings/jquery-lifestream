(function(angular) {

  'use strict';

  /**
   * Badges Factory - get data from the badges API
   * @param {Object} apiService CalCentral API Service
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('badgesFactory', function(apiService, $http) {

    var url = '/api/my/badges';

    var getBadges = function(options) {
      apiService.util.clearCache(options, url);
      return $http.get(url, {
        cache: true
      });
    };

    return {
      getBadges: getBadges
    };

  });

}(window.angular));
