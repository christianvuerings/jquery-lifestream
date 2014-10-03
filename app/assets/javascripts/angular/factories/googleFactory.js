(function(angular) {
  'use strict';

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
}(window.angular));
