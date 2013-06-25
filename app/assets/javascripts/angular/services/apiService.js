(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', [
    'analyticsService',
    'apiEventService',
    'dateService',
    'errorService',
    'popoverService',
    'refreshService',
    'userService',
    'utilService',
    'widgetService',
    function(
      analyticsService,
      apiEventService,
      dateService,
      errorService,
      popoverService,
      refreshService,
      userService,
      utilService,
      widgetService) {

    // API
    var api = {
      analytics: analyticsService,
      events: apiEventService,
      date: dateService,
      error: errorService,
      popover: popoverService,
      refresh: refreshService,
      user: userService,
      util: utilService,
      widget: widgetService
    };

    return api;

  }]);

}(window.angular));
