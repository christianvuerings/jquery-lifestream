(function(angular) {

  'use strict';

  /**
   * Roster Factory - get data from the roster API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('rosterFactory', function($http) {

    /**
     * Get the roster information
     * @param {String} mode 'canvas' or 'campus'
     * @param {String} id ID of the course
     */
    var getRoster = function(mode, id) {
      var url = '/api/academics/rosters/' + mode + '/' + id;
      return $http.get(url);
    };

    return {
      getRoster: getRoster
    };

  });

}(window.angular));
