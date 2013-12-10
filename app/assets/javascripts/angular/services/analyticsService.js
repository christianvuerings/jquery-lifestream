(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('analyticsService', function($rootScope, $window, $location) {

    /**
     * Adding a track property to the analytics object
     * @param {Array} property Array of the property you want to add
     */
    var addTrackProperty = function(property) {
      // We should check whether the Google Analytics script has been loaded
      if ($window._gaq) {
        $window._gaq.push(property);
      }
    };

    /**
     * Track an event on the page
     * @param {Array} eventtrack An array of what you want to track.
     * In this order: category - action - label - value and non-interaction
     * e.g. ['Videos', 'Play', 'Flying to Belgium']
     * More info on https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide
     */
    var trackEvent = function(eventtrack) {
      addTrackProperty(['_trackEvent'].concat(eventtrack));
    };

    /**
     * Track when there is an external link being clicked
     * @param {String} section The section you're currently in (e.g. Up Next / My Classes / Activity)
     * @param {String} website The website you're trying to access (Google Maps)
     * @param {String} url The URL you're accessing
     */
    var trackExternalLink = function(section, website, url) {
      trackEvent(['External link', url , 'section: ' + section + ' - website: ' + website]);
    };

    /**
     * This will track the the page that you're viewing
     * e.g. /, /dashboard, /settings
     */
    var trackPageview = function() {
      addTrackProperty(['_trackPageview', $location.path()]);
    };

    // Whenever we're changing the content loaded, we need to track which page we're viewing.
    $rootScope.$on('$viewContentLoaded', trackPageview);

    // Expose methods
    return {
      trackEvent: trackEvent,
      trackExternalLink: trackExternalLink
    };

  });

}(window.angular));
