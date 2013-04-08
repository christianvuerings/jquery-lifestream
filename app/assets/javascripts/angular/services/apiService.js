(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', [
    'analyticsService',
    'dateService',
    'errorService',
    'popoverService',
    'utilService',
    'widgetService',
    function(
      analyticsService,
      dateService,
      errorService,
      popoverService,
      utilService,
      widgetService) {

    // API
    var api = {
      analytics: analyticsService,
      date: dateService,
      error: errorService,
      popover: popoverService,
      util: utilService,
      widget: widgetService
    };

    return api;

  }]);

}(window.angular));
