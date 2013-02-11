(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('utilService', ['$rootScope', function($rootScope) {

    /**
     * Prevent a click event from bubbling up to its parents
     */
    var preventBubble = function($event) {
      $event.stopPropagation();
    };

    /**
     * Set the title for the current web page
     * @param {String} title The title that you want to show for the current web page
     */
    var setTitle = function(title) {
      $rootScope.title = title + ' | CalCentral';
    };

    // Expose methods
    return {
      preventBubble: preventBubble,
      setTitle: setTitle
    };

  }]);

}(window.angular));
