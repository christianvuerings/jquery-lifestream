(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', [
    'analyticsService',
    'popoverService',
    'utilService',
    'widgetService',
    function(analyticsService, popoverService, utilService, widgetService) {

    // API
    var api = {};

    api.analytics = analyticsService;
    api.popover = popoverService;
    api.util = utilService;
    api.widget = widgetService;

    return api;

  }]);

}(window.angular));
