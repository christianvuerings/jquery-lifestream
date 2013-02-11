(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('widgetService', ['analyticsService', function(analyticsService) {

    /**
     * Toggle whether an item for a widget should be shown or not
     */
    var toggleShow = function(item, widget) {
      item.show = !item.show;
      analyticsService.trackEvent(['Detailed view', item.show ? 'Open' : 'Close', widget]);
    };

    /**
     * Check whether there is one item in the list that is shown
     * @return {Boolean} Will be true when there is one item in the list that is shown
     */
    var containsOpen = function(items) {
      if (!items) {
        return;
      }

      for(var i = 0; i < items.length; i++){
        if (items[i].show) {
          return true;
        }
      }
      return false;
    };

    // Expose the methods
    return {
      toggleShow: toggleShow,
      containsOpen: containsOpen
    };

  }]);

}(window.angular));
