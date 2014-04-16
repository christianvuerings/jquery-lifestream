(function(angular) {

  'use strict';

  /**
   * Cal1Card Factory - get data from the cal1card API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('cal1CardFactory', function($http) {

    var getCal1Card = function() {
      return $http.get('/api/my/cal1card');
      // return $http.get('/dummy/json/cal1card.json');
    };

    return {
      getCal1Card: getCal1Card
    };

  });

}(window.angular));
