'use strict';

var angular = require('angular');

/**
 * CalCentral main controller
 */
angular.module('calcentral.controllers').controller('CalcentralController', function(apiService, $rootScope) {
  // Expose the API service
  $rootScope.api = apiService;

  /**
   * Will be executed on every route change
   *  - Get the user information when it hasn't been loaded yet
   *  - Handle the page access
   *  - Send the right controller name
   */
  $rootScope.$on('$routeChangeSuccess', function(evt, current) {
    apiService.events.fireApiEvents($rootScope.api);
    apiService.user.handleRouteChange();
    apiService.util.changeControllerName(current.controller);
    apiService.util.checkIsBcourses();
    apiService.analytics.load();
    apiService.util.hideOffCanvasMenu();
    apiService.auth.isLoggedInRedirect();
    apiService.updatedFeeds.initiate(current.$$route, $rootScope);
  });
});
