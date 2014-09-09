(function(angular) {

  'use strict';

  /**
   * Badges Factory - get data from the badges API
   * @param {Object} $cacheFactory The $cacheFactory service from Angular
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('badgesFactory', function($cacheFactory, $http) {

    var url = '/api/my/badges';

    var getBadges = function(options) {
      if (options && options.refreshCache) {
        $cacheFactory.get('$http').remove(url);
      }
      return $http.get(url, {
        cache: true
      });
    };

    return {
      getBadges: getBadges
    };

  });

}(window.angular));
