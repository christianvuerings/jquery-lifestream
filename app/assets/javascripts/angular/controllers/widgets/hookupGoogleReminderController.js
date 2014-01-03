(function(angular) {
  'use strict';

  /**
   * Hookup Google Reminder controller
   */
  angular.module('calcentral.controllers').controller('HookupGoogleReminderController', function($http, $scope, apiService) {

    $scope.dismissReminder = function() {
      $http.post('/api/google/dismiss_reminder').success(function() {
        apiService.analytics.trackEvent(['Preferences', 'Dismiss bConnected reminder card']);
        $scope.showReminderCard = false;
        //force the user.profile to refresh since status has changed.
        $scope.api.user.fetch();
      });
    };

    $scope.showReminderCard = true;

    $scope.$watch('api.user.profile.has_google_access_token + \',\' + api.user.profile.is_google_reminder_dismissed', function(newTokenTuple) {
      var dismissReminderFields = newTokenTuple.split(',');
      if (dismissReminderFields[0] === 'true' || dismissReminderFields[1] === 'true') {
        $scope.showReminderCard = false;
      }
    });

  });

})(window.angular);
