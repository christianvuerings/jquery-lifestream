(function(angular) {

  'use strict';

  /**
   * Badges Factory - get data from the badges API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('badgesFactory', function($http) {

    var getBadges = function() {
      return $http.get('/api/my/badges');
    };

    return {
      getBadges: getBadges
    };

  });

}(window.angular));
