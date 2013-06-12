(function(window, calcentral) {
  'use strict';

  /**
   * CalCentral main controller
   */
  calcentral.controller('CalcentralController', ['$scope', 'apiService', function($scope, apiService) {

    // Expose the API service
    $scope.api = apiService;

    /**
     * Broadcast an API event
     * in order for an API to broadcast events, it need to have an 'events' property
     * @param {String} apiName The name of the event
     * @param {String} eventName The name of the event
     * @param {Object} data Data that you want to send with the event
     */
    var broadcastApiEvent = function(apiName, eventName, data) {
      $scope.$broadcast('calcentral.api.' + apiName + '.' + eventName, data);
    };

    /**
     * Watch the event for a certain part of the API
     * @param {String} apiName The name of the API you want to watch (e.g. user)
     * @param {String} eventName The name of the event (isUserLoaded)
     */
    var watchEvent = function(apiName, eventName) {
      $scope.$watch('api.' + apiName + '.events.' + eventName, function(data) {
        broadcastApiEvent(apiName, eventName, data);
      }, true);
    };

    /**
     * Fire the events for the API
     * @return {[type]} [description]
     */
    var fireApiEvents = function() {
      for (var i in $scope.api) {
        if ($scope.api.hasOwnProperty(i) && $scope.api[i].events) {
          for (var j in $scope.api[i].events) {
            if ($scope.api[i].events.hasOwnProperty(j)) {
              watchEvent(i, j);
            }
          }
        }
      }
    };

    /**
     * Will be executed on every route change
     *  - Get the user information when it hasn't been loaded yet
     *  - Handle the page access
     *  - Send the right controller name
     */
    $scope.$on('$routeChangeSuccess', function(evt, current) {
      fireApiEvents();
      apiService.user.handleRouteChange();
      apiService.util.changeControllerName(current.controller);
    });

  }]);

})(window, window.calcentral);
