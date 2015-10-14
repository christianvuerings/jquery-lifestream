'use strict';

var angular = require('angular');

/**
 * Finaid COA (Cost of Attendance) controller
 */
angular.module('calcentral.controllers').controller('FinaidApprovalsController', function($rootScope, $scope, finaidFactory) {
  $scope.approvalMessage = {};

  /**
   * Send an event to let everyone know the permissions have been updated.
   */
  var sendEvent = function() {
    $rootScope.$broadcast('calcentral.custom.api.finaid.approvals');
  };

  var showDeclineMessage = function(data) {
    angular.extend($scope.approvalMessage, data.data.feed);
  };

  $scope.sendResponseTC = function(finaidYearId, response) {
    finaidFactory.postTCResponse(finaidYearId, response).then(function(data) {
      if (response === 'N') {
        showDeclineMessage(data);
      } else {
        sendEvent();
      }
    });
  };
  $scope.sendResponseT4 = function(response) {
    finaidFactory.postT4Response(response).then(sendEvent);
  };
});
