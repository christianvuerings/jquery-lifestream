(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('popoverService', function($document, $rootScope) {

    var popovers = {};

    /**
     * Close all the popovers
     */
    var closeAll = function() {
      popovers = {};
    };

    /**
     * Close all the popovers when it's initiated from a click on the document
     * We need to do a $scope.$apply in order to fill in the $scope
     */
    var closeAllClick = function() {
      closeAll();
      $rootScope.$apply();
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
     * Bind the event handlers for the document
     * @param {Boolean} popoverShown Whether a popover is shown
     */
    var bindEventHandlers = function(popoverShown) {
      if (popoverShown) {
        $document.bind('click', closeAllClick);
      } else {
        $document.unbind('click', closeAllClick);
      }
    };

    /**
     * Toggle a certain popover
     * @param {String} popover Popover name
     */
    var toggle = function(popover) {
      closeOthers(popover);
      popovers[popover] = !popovers[popover];
      bindEventHandlers(popovers[popover]);
    };

    // Expose methods
    return {
      closeAll: closeAll,
      status: status,
      toggle: toggle
    };

  });

}(window.angular));
