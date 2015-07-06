(function(angular) {
  'use strict';

  angular.module('calcentral.services').service('updatedFeedsService', function($http, $timeout, userService) {
    var events = {
      updateServices: {},
      servicesWithUpdates: {}
    };
    var feedsLoadedData = {};
    // Polling time in seconds
    var pollIntervals = [2, 3, 10, 45, 60];

    // In the first iteration, we only update the services on the dashboard page.
    var toUpdateServices = [
      'MyActivities::Merged',
      'MyBadges::Merged',
      'MyClasses::Merged',
      'MyGroups::Merged',
      'MyTasks::Merged',
      'UpNext::MyUpNext'
    ];

    /**
     * Check whether there are updated to any of the feeds.
     * @return {Boolean} True if there are any updates
     */
    var hasUpdates = function() {
      return !!Object.keys(events.servicesWithUpdates).length;
    };

    /**
     * Refresh all the feeds that have actual changes.
     */
    var refreshFeeds = function() {
      events.updateServices = events.servicesWithUpdates;

      // We need to wrap this in a timeout to make sure the events actually fire
      $timeout(function() {
        events.servicesWithUpdates = {};
        events.updateServices = {};
      }, 1);
    };

    /**
     * Parse the updated feeds
     * @param {Object} data JSON coming back from the server, contains which feeds need an update
     * @param {Boolean} autoRefresh Whether or not to automatically update the feeds or not
     */
    var parseUpdatedFeeds = function(data, autoRefresh) {
      // When there is no data, don't do anything.
      if (!data) {
        return;
      }

      for (var service in data) {
        if (data.hasOwnProperty(service) && toUpdateServices.indexOf(service) !== -1) {
          // We need to check whether the timestamps are different or not
          if (data[service] &&
            feedsLoadedData[service] &&
            data[service].timestamp &&
            feedsLoadedData[service].timestamp &&
            data[service].timestamp.epoch > feedsLoadedData[service].timestamp.epoch) {
            events.servicesWithUpdates[service] = data[service];
          }
        }
      }

      if (autoRefresh) {
        refreshFeeds();
      }
    };

    var polling = function(autoRefresh) {
      // $http.get('/dummy/json/updated_feeds.json').success(function(data) {
      $http.get('/api/my/updated_feeds').success(function(data) {
        parseUpdatedFeeds(data, autoRefresh);
        $timeout(polling, getPollInterval() * 1000);
      }).error(function(data, responseCode) {
        if (responseCode && responseCode === 401) {
          userService.signOut();
        }
      });
    };

    /**
     * Initiate the polling to the back-end to check whether there are any updates
     */
    var startPolling = function() {
      // Show the loading spinning indicator
      $timeout(function() {
        polling(true);
      }, getPollInterval() * 1000);
    };

    /**
     * Increment though the defined pollIntervals and return the last one
     * when the end has been reached.
     * @return {Integer}
     */
    var getPollInterval = function() {
      return (pollIntervals.length > 1) ? pollIntervals.shift() : pollIntervals[0];
    };

    /**
     * Check the properties on the feed data that is coming back
     * @param {Object} data Feed data
     * @return {Boolean} True when it's valid
     */
    var isValidFeed = function(data) {
      return !!(data && data.feedName && data.lastModified);
    };

    /**
     * Add data from the feed to the overall object
     * We also add counts to see whether we need to automatically reload the feed or not.
     * @param {Object} data Feed data
     */
    var addFeedData = function(data) {
      feedsLoadedData[data.feedName] = data.lastModified;
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
      var isLoggedInWatch = scope.$watch('api.user.profile.isLoggedIn', function(isLoggedIn) {
        if (isLoggedIn) {
          // Refresh the services, we only want to do this on certain pages
          if (route && route.fireUpdatedFeeds) {
            startPolling();
          }

          // This will unwatch the watcher (performance reasons)
          isLoggedInWatch();
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
