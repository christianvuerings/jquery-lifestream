(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', function(
      analyticsService,
      authService,
      apiEventService,
      dateService,
      errorService,
      httpService,
      popoverService,
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
      http: httpService,
      popover: popoverService,
      updatedFeeds: updatedFeedsService,
      user: userService,
      util: utilService,
      widget: widgetService
    };

    return api;

  });

}(window.angular));
