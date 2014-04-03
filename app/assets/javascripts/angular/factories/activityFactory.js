(function(angular) {

  'use strict';

  /**
   * Activity Factory - get data from the activity API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('activityFactory', function($http) {

    var getActivity = function() {
      return $http.get('/api/my/activities');
      // return $http.get('/dummy/json/activities.json');
    };

    return {
      getActivity: getActivity
    };

  });

}(window.angular));
