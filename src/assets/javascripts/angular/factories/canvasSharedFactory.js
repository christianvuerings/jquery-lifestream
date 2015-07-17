'use strict';

var angular = require('angular');

/**
 * Canvas Shared Factory - Interface for shared API endpoints
 */
angular.module('calcentral.factories').factory('canvasSharedFactory', function($http) {
  var courseUserRoles = function(canvasCourseId) {
    return $http.get('/api/academics/canvas/course_user_roles/' + canvasCourseId);
  };

  return {
    courseUserRoles: courseUserRoles
  };
});
