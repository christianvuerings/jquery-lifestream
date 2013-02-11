(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('apiService', ['analyticsService', 'utilService', 'widgetService', function(analyticsService, utilService, widgetService) {

    // API
    var api = {};

    api.analytics = analyticsService;
    api.util = utilService;
    api.widget = widgetService;

    return api;

  }]);

}(window.angular));
