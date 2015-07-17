'use strict';

var angular = require('angular');

/**
 * Google Factory
 */
angular.module('calcentral.factories').factory('googleFactory', function($http) {
  var dismissReminderUrl = '/api/google/dismiss_reminder';

  var dismissReminder = function() {
    return $http.post(dismissReminderUrl);
  };

  return {
    dismissReminder: dismissReminder
  };
});
