(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('widgetService', ['analyticsService', '$timeout', function(analyticsService, $timeout) {

    /**
     * Toggle whether an item for a widget should be shown or not
     */
    var toggleShow = function(event, items, item, widget) {
      // Ignore toggling on Anchor events
      if (event && event.toElement && event.toElement.tagName === 'A') {
        return;
      }

      // Toggle the current item
      item._show = !item._show;

      // Hide all the other items
      if (angular.isArray(items)) {
        for (var i = 0; i < items.length; i++) {
          if (items[i].$$hashKey !== item.$$hashKey) {
            items[i]._show = false;
          }
        }
      }

      // Also make it work for objects
      if (angular.isObject(items)) {
        for (var j in items) {
          if (items.hasOwnProperty(j) && items[j].$$hashKey !== item.$$hashKey) {
            items[j]._show = false;
          }
        }
      }

      // Scroll to element so it is in the browsers viewport
      if (event && event.toElement && item._show) {
        var scrollIntoView = function() {event.toElement.scrollIntoView()};
        $timeout(scrollIntoView, 1);
      }

      analyticsService.trackEvent(['Detailed view', item._show ? 'Open' : 'Close', widget]);
    };

    // Expose the methods
    return {
      toggleShow: toggleShow
    };

  }]);

}(window.angular));
