'use strict';

var angular = require('angular');

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
