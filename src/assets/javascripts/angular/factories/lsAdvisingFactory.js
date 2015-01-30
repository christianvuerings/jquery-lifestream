(function(angular) {
  'use strict';

  /**
   * L & S Advising Factory
   */
  angular.module('calcentral.factories').factory('lsAdvisingFactory', function($http) {
    var getAdvisingInfo = function() {
      // return $http.get('/dummy/json/lsadvising2.json');
      return $http.get('/api/my/advising');
    };

    return {
      getAdvisingInfo: getAdvisingInfo
    };
  });
}(window.angular));
