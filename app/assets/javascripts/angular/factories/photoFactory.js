(function(angular) {

  'use strict';

  /**
   * Photo Factory - get data from the photo API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('photoFactory', function($http) {

    var hasPhoto = function() {
      return $http.get('/api/my/has_photo', {
        cache: true
      });
    };

    return {
      hasPhoto: hasPhoto
    };

  });

}(window.angular));
