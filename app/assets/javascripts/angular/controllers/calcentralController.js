(function(window, angular) {
  'use strict';

  /**
   * CalCentral main controller
   */
  angular.module('calcentral.controllers').controller('CalcentralController', function($rootScope, apiService) {

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
      apiService.auth.isLoggedInRedirect();
      apiService.updatedFeeds.initiate(current.$$route, $rootScope);
    });

  });

})(window, window.angular);
