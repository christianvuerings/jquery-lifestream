(function(angular){

  'use strict';

  angular.module('calcentral.services').service('updatedFeedsService', function($http, $timeout, userService) {

    var events = {
      is_loading: false,
      update_services: {},
      services_with_updates: {}
    };
    var feedsLoadedData = {};
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

          // We need to check whether the timestamps are different or not
          if (data[service] &&
            feedsLoadedData[service] &&
            data[service].timestamp  &&
            feedsLoadedData[service].timestamp &&
            data[service].timestamp.epoch > feedsLoadedData[service].timestamp.epoch) {

            events.services_with_updates[service] = data[service];
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
        events.is_loading = false;
        parseUpdatedFeeds(data, auto_refresh);

        // Now we poll every 60 seconds
        $timeout(polling, polling_time * 1000);
      }).error(function(data, response_code) {
        if (response_code && response_code === 401) {
          userService.signOut();
        }
      });
    };

    /**
     * Initiate the polling to the back-end to check whether there are any updates
     */
    var startPolling = function() {

      // Show the loading spinning indicator
      events.is_loading = true;

      // First time we poll at 10 seconds
      $timeout(function() {
        polling(true);
      }, initial_polling_time * 1000);
    };

    /**
     * Check the properties on the feed data that is coming back
     * @param {Object} data Feed data
     * @return {Boolean} True when it's valid
     */
    var isValidFeed = function(data) {
      return !!(data && data.feed_name && data.last_modified);
    };

    /**
     * Add data from the feed to the overall object
     * We also add counts to see whether we need to automatically reload the feed or not.
     * @param {Object} data Feed data
     */
    var addFeedData = function(data) {
      feedsLoadedData[data.feed_name] = data.last_modified;
    };

    /**
     * When a live update feed has loaded, this function gets executed
     * @param {data} data JSON coming back from the server
     */
    var feedLoaded = function(data) {
      if (isValidFeed(data)) {
        addFeedData(data);
      }
    };

    /**
     * Initiate the updated feeds service
     * This will check whether the current route should poll or not
     */
    var initiate = function(route, scope) {

      var isLoggedIn = scope.$watch('api.user.profile.is_logged_in', function(is_logged_in) {
        if (is_logged_in) {
          // Refresh the services, we only want to do this on certain pages
          if (route && route.fireUpdatedFeeds) {
            startPolling();
          }

          // This will unwatch the watcher (performance reasons)
          isLoggedIn();
        }
      });

    };

    /**
     * Expose the public methods
     */
    return {
      events: events,
      feedLoaded: feedLoaded,
      hasUpdates: hasUpdates,
      initiate: initiate,
      refreshFeeds: refreshFeeds,
      startPolling: startPolling
    };

  });

})(window.angular);
