'use strict';

var angular = require('angular');

angular.module('calcentral.services').service('analyticsService', function(calcentralConfig, $rootScope, $location) {
  /**
   * Send an analytics event
   * @param {String} category e.g. Video
   * @param {String} action e.g. Play
   * @param {String} label e.g. Flying to Belgium
   * More info on https://developers.google.com/analytics/devguides/collection/analyticsjs/events
   */
  var sendEvent = function(category, action, label) {
    window.ga('send', 'event', category, action, label);
  };

  /**
   * Set the user id for the analytics service
   * @param {String} uid The uid of the current user
   */
  var setUserId = function(uid) {
    if (uid) {
      window.ga('set', '&uid', uid);
    }
  };

  /**
   * Track when there is an external link being clicked
   * @param {String} section The section you're currently in (e.g. Up Next / My Classes / Activity)
   * @param {String} website The website you're trying to access (Google Maps)
   * @param {String} url The URL you're accessing
   */
  var trackExternalLink = function(section, website, url) {
    sendEvent('External link', url, 'section: ' + section + ' - website: ' + website);
  };

  /**
   * This will track the the page that you're viewing
   * e.g. /, /dashboard, /settings
   */
  var trackPageview = function() {
    window.ga('send', 'pageview', $location.path());
  };

  /* jshint ignore:start */
  // jscs:disable
  /**
   * Inject the Google Analytics code
   */
  var injectAnalyticsCode = function() {
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

    window.ga('create', calcentralConfig.googleAnalyticsId , 'auto');
  };
  // jscs:enable
  /* jshint ignore:end */

  /**
   * Load the Google Analytics service
   */
  var load = function() {
    /* jshint ignore:start */
    injectAnalyticsCode(calcentralConfig.googleAnalyticsId);
    /* jshint ignore:end */

    setUserId(calcentralConfig.uid);
  };

  // Whenever we're changing the content loaded, we need to track which page we're viewing.
  $rootScope.$on('$viewContentLoaded', trackPageview);

  // Expose methods
  return {
    load: load,
    sendEvent: sendEvent,
    trackExternalLink: trackExternalLink
  };
});
