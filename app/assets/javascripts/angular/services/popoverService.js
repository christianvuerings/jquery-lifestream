(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('popoverService', [function() {

    var popovers = {};

    /**
     * Close all the popovers
     */
    var closeAll = function() {
      popovers = {};
    };

    /**
     * Close all the popovers apart from the one you're passing in
     * @param {String} popover Popover name
     */
    var closeOthers = function(popover) {
      var popoverStatus = popovers[popover];
      closeAll();
      popovers[popover] = popoverStatus;
    };

    /**
     * Get the current popover status
     * @param {String} popover Popover name
     */
    var status = function(popover) {
      return !!popovers[popover];
    };

    /**
     * Toggle a certain popover
     * @param {String} popover Popover name
     */
    var toggle = function(popover) {
      closeOthers(popover);
      popovers[popover] = !popovers[popover];
    };

    // Expose methods
    return {
      closeAll: closeAll,
      status: status,
      toggle: toggle
    };

  }]);

}(window.angular));
