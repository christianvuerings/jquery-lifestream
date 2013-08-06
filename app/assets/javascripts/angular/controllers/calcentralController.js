(function(window, calcentral) {
  'use strict';

  /**
   * CalCentral main controller
   */
  calcentral.controller('CalcentralController', ['$rootScope', 'apiService', function($rootScope, apiService) {

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

      // Refresh the services, we only want to do this on certain pages
      if (current.$$route.shouldRefresh) {
        apiService.refresh.startRefresh();
      }
    });

  }]);

})(window, window.calcentral);
