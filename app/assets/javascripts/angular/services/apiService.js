(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', [
    'analyticsService',
    'dateService',
    'errorService',
    'popoverService',
    'userService',
    'utilService',
    'widgetService',
    function(
      analyticsService,
      dateService,
      errorService,
      popoverService,
      userService,
      utilService,
      widgetService) {

    // API
    var api = {
      analytics: analyticsService,
      date: dateService,
      error: errorService,
      popover: popoverService,
      user: userService,
      util: utilService,
      widget: widgetService
    };

    return api;

  }]);

}(window.angular));
