(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('utilService', ['$location', '$rootScope', function($location, $rootScope) {

    /**
     * Pass in controller name so we can set active location in menu
     * @param {String} name The name of the controller
     */
    var changeControllerName = function(name) {
      $rootScope._controller_name = name;
    };

    /**
     * Redirect to a page
     */
    var redirect = function(page) {
      $location.path('/' + page);
    };

    /**
     * Prevent a click event from bubbling up to its parents
     */
    var preventBubble = function($event) {
      $event.stopPropagation();
      // When it's not an anchor tag, we also prevent the default event
      if ($event.target.nodeName !== 'A') {
        $event.preventDefault();
      }
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
      changeControllerName: changeControllerName,
      preventBubble: preventBubble,
      redirect: redirect,
      setTitle: setTitle
    };

  }]);

}(window.angular));
