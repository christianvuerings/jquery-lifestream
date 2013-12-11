(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('refreshService', ['$http', function($http) {

    var events = {
      refreshed: 0
    };

    /**
     * Refresh will do the following:
     *   - Sleep for x seconds
     *   - Expire the user cache
     *   - Warm up the user cache
     *   - Returns 200 if a warmup was performed,
     *     304 if no warmup was performed (because it was done too recently),
     *     and 401 if the user is anonymous.
     * As soon as this function start and also when it's finished, we should update all the widgets
     */
    var startRefresh = function() {
      events.refreshed++;

      // This success is only going to happen when we get a 2xx back
      // We won't get a 2xx back when the refresh is cached
      $http.get('/api/my/refresh').success(function() {
        events.refreshed++;
      });
    };

    // Expose methods
    return {
      events: events,
      startRefresh: startRefresh
    };

  }]);

}(window.angular));
