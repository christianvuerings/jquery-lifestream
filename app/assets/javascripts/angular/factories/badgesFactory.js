(function(angular) {

  'use strict';

  angular.module('calcentral.factories').factory('badgesFactory', function($http) {

    var getBadges = function() {
      return $http.get('/api/my/badges');
    };

    return {
      getBadges: getBadges
    };

  });

}(window.angular));
