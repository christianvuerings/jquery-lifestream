'use strict';

var angular = require('angular');

/**
 * Roster Factory
 */
angular.module('calcentral.factories').factory('rosterFactory', function($http) {
  /**
   * Get the roster information
   * @param {String} context 'canvas' or 'campus'
   * @param {String} courseId ID of the course
   */
  var getRoster = function(context, courseId) {
    var url = '/api/academics/rosters/' + context + '/' + courseId;
    return $http.get(url);
  };

  return {
    getRoster: getRoster
  };
});
