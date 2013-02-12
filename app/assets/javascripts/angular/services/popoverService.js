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
