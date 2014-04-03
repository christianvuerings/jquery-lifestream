(function(angular) {

  'use strict';

  /**
   * Finances Factory - get data from the badges API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('financesFactory', function($http) {

    var getFinances = function() {
      return $http.get('/api/my/financials');
    };

    return {
      getFinances: getFinances
    };

  });

}(window.angular));
