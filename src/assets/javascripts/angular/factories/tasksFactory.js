'use strict';

var angular = require('angular');

/**
 * Tasks Factory
 */
angular.module('calcentral.factories').factory('tasksFactory', function(apiService, $http) {
  var clearCompletedUrl = '/api/my/tasks/clear_completed';
  var removeUrl = '/api/my/tasks/delete/';
  var url = '/api/my/tasks';

  var clearCompletedTasks = function(params) {
    return $http.post(clearCompletedUrl, params);
  };

  var remove = function(task) {
    return $http.post(removeUrl + task.id, task);
  };

  var getTasks = function(options) {
    return apiService.http.request(options, url);
  };

  var update = function(task) {
    return $http.post(url, task);
  };

  return {
    clearCompletedTasks: clearCompletedTasks,
    remove: remove,
    getTasks: getTasks,
    update: update
  };
});
