(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', [
    'analyticsService',
    'dateService',
    'popoverService',
    'utilService',
    'widgetService',
    function(analyticsService, dateService, popoverService, utilService, widgetService) {

    // API
    var api = {};

    api.analytics = analyticsService;
    api.date = dateService;
    api.popover = popoverService;
    api.util = utilService;
    api.widget = widgetService;

    return api;

  }]);

}(window.angular));
