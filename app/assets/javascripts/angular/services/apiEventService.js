(function(angular) {

  'use strict';

  /**
   * API event service - broadcasts API events
   */
  angular.module('calcentral.services').service('apiEventService', function($rootScope) {

    /**
     * Broadcast an API event
     * in order for an API to broadcast events, it need to have an 'events' property
     * @param {String} apiName The name of the event
     * @param {String} eventName The name of the event
     * @param {Object} data Data that you want to send with the event
     */
    var broadcastApiEvent = function(apiName, eventName, data) {
      // console.log('calcentral.api.' + apiName + '.' + eventName, data);
      $rootScope.$broadcast('calcentral.api.' + apiName + '.' + eventName, data);
    };

    /**
     * Watch the event for a certain part of the API
     * @param {String} apiName The name of the API you want to watch (e.g. user)
     * @param {String} eventName The name of the event (isUserLoaded)
     */
    var watchEvent = function(apiName, eventName) {
      $rootScope.$watch('api.' + apiName + '.events.' + eventName, function(data) {
        broadcastApiEvent(apiName, eventName, data);
      }, true);
    };

    /**
     * Fire the events for the API
     * @return {[type]} [description]
     */
    var fireApiEvents = function(api) {
      for (var i in api) {
        if (api.hasOwnProperty(i) && api[i].events) {
          for (var j in api[i].events) {
            if (api[i].events.hasOwnProperty(j)) {
              watchEvent(i, j);
            }
          }
        }
      }
    };

    // Expose methods
    return {
      fireApiEvents: fireApiEvents
    };

  });

}(window.angular));
