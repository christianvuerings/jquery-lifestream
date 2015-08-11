'use strict';

var angular = require('angular');

/**
 * Directive for the finaid permissions
 */
angular.module('calcentral.directives').directive('ccFinaidPermissionsDirective', function() {
  return {
    templateUrl: 'directives/finaid_permissions.html',
    scope: {
      buttonActionApprove: '&',
      buttonActionDontApprove: '&',
      buttonGoBack: '=',
      buttonTextApprove: '=',
      buttonTextDontApprove: '=',
      header: '=',
      text: '=',
      title: '='
    }
  };
});
