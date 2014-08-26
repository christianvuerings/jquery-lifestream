(function(angular) {

  'use strict';

  /**
   * Academics Factory - get data from the academics API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('academicsFactory', function($http) {

    var getAcademics = function() {
      // return $http.get('/dummy/json/academics.json');
      return $http.get('/api/my/academics');
    };

    return {
      getAcademics: getAcademics
    };

  });

}(window.angular));
