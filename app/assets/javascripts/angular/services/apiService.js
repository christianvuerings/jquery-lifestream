(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', function(
      analyticsService,
      authService,
      apiEventService,
      dateService,
      errorService,
      popoverService,
      refreshService,
      updatedFeedsService,
      userService,
      utilService,
      widgetService) {

      // API
      var api = {
        analytics: analyticsService,
        auth: authService,
        events: apiEventService,
        date: dateService,
        error: errorService,
        popover: popoverService,
        refresh: refreshService,
        updatedFeeds: updatedFeedsService,
        user: userService,
        util: utilService,
        widget: widgetService
      };

      return api;

    }
  );

}(window.angular));
