(function(angular){

  'use strict';

  angular.module('calcentral.services').service('updatedFeedsService', [
    '$http',
    '$timeout', function(
      $http,
      $timeout) {

    var events = {
      update_services: {},
      services_with_updates: {}
    };
    var services = {};
    var start_polling_time = 10; // Start polling time in seconds
    var polling_time = 60; // Polling time in seconds

    // In the first iteration, we only update the services on the dashboard page.
    var to_update_services = ['MyActivities::Merged', 'MyClasses', 'MyGroups', 'MyTasks::Merged', 'MyUpNext'];

    var hasUpdates = function() {
      return !!Object.keys(events.services_with_updates).length;
    };

    var refreshFeeds = function() {
      events.update_services = events.services_with_updates;

      // We need to wrap this in a timeout to make sure the events actually fire
      $timeout(function() {
        events.services_with_updates = {};
        events.update_services = {};
        services = {};
      }, 1);
    };

    var getUpdatedFeeds = function(data) {
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
    };

    var polling = function() {
      $http.get('/api/my/updated_feeds').success(getUpdatedFeeds);
      //$http.get('/dummy/json/updated_feeds.json').success(getUpdatedFeeds);
      $timeout(polling, polling_time * 1000);
    };

    var startPolling = function() {
      $timeout(polling, start_polling_time * 1000);
    };

    return {
      events: events,
      hasUpdates: hasUpdates,
      refreshFeeds: refreshFeeds,
      startPolling: startPolling
    };

  }]);

})(window.angular);
