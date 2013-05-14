(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('widgetService', ['analyticsService', function(analyticsService) {

    /**
     * Toggle whether an item for a widget should be shown or not
     */
    var toggleShow = function(items, item, widget) {

      // Toggle the current item
      item._show = !item._show;

      // Hide all the other items
      for (var i = 0; i < items.length; i++) {
        if (items[i].$$hashKey !== item.$$hashKey) {
          items[i]._show = false;
        }
      }
      analyticsService.trackEvent(['Detailed view', item._show ? 'Open' : 'Close', widget]);
    };

    // Expose the methods
    return {
      toggleShow: toggleShow
    };

  }]);

}(window.angular));
