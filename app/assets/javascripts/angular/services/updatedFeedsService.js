(function(angular){

  'use strict';

  angular.module('calcentral.services').service('updatedFeedsService', [
    '$http',
    '$timeout',
    'userService',
    function(
      $http,
      $timeout,
      userService) {

    var events = {
      is_loading: false,
      update_services: {},
      services_with_updates: {}
    };
    var services = {};
    var initial_polling_time = 10; // Initial polling time in seconds
    var polling_time = 60; // Polling time in seconds

    // In the first iteration, we only update the services on the dashboard page.
    var to_update_services = [
      'MyActivities::Merged',
      'MyBadges::Merged',
      'MyClasses',
      'MyGroups',
      'MyTasks::Merged',
      'MyUpNext'
    ];

    /**
     * Check whether there are updated to any of the feeds.
     * @return {Boolean} True if there are any updates
     */
    var hasUpdates = function() {
      return !!Object.keys(events.services_with_updates).length;
    };

    /**
     * Refresh all the feeds that have actual changes.
     */
    var refreshFeeds = function() {
      events.update_services = events.services_with_updates;

      // We need to wrap this in a timeout to make sure the events actually fire
      $timeout(function() {
        events.services_with_updates = {};
        events.update_services = {};
        services = {};
      }, 1);
    };

    /**
     * Parse the updated feeds
     * @param {Object} data JSON coming back from the server, contains which feeds need an update
     * @param {Boolean} auto_refresh Whether or not to automatically update the feeds or not
     */
    var parseUpdatedFeeds = function(data, auto_refresh) {

      // When there is no data, don't do anything.
      if (!data) {
        return;
      }

      for (var service in data) {
        if (data.hasOwnProperty(service) && to_update_services.indexOf(service) !== -1) {
          // The first time we encounter it, we just need to add it to the list
          if (!services[service]) {
            services[service] = data[service];
          // The next time, we need to check whether the timestamps are different or not
          } else if (services[service] && services[service].timestamp !== data[service].timestamp) {
            events.services_with_updates[service] = services[service];
          }
        }
      }

      if (auto_refresh) {
        refreshFeeds();
      }
    };

    var polling = function(auto_refresh) {
      $http.get('/api/my/updated_feeds').success(function(data) {
      //$http.get('/dummy/json/updated_feeds.json').success(function(data) {
        parseUpdatedFeeds(data, auto_refresh);
      }).error(function(data, response_code) {
        if (response_code && response_code === 401) {
          userService.signOut();
        }
      });

      if (events.is_loading) {

        // Second time we poll at 10 seconds and automatically refresh the feeds
        $timeout(function() {
          events.is_loading = false;
          polling(true);
        }, initial_polling_time * 1000);
      } else {
        // Now we poll every 60 seconds
        $timeout(polling, polling_time * 1000);
      }
    };

    /**
     * Initiate the polling to the back-end to check whether there are any updates
     */
    var startPolling = function() {

      // Show the loading spinning indicator
      events.is_loading = true;

      // First time we poll at 0 seconds
      polling();
    };

    /**
     * Expose the public methods
     */
    return {
      events: events,
      hasUpdates: hasUpdates,
      refreshFeeds: refreshFeeds,
      startPolling: startPolling
    };

  }]);

})(window.angular);
