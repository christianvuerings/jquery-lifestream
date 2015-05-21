(function(angular, naturalSort) {
  'use strict';

  angular.module('calcentral.services').service('utilService', function($cacheFactory, $http, $location, $rootScope, $route, $window) {
    /**
     * Check whether the current browser can play mp3 files
     * Based on Modernizr: http://git.io/DPOxlQ
     */
    var canPlayMp3 = function() {
      var canPlay = false;
      var element = document.createElement('audio');

      try {
        var hasAudioElement = !!element.canPlayType;
        if (hasAudioElement) {
          canPlay = element.canPlayType('audio/mpeg;');
        }
      } catch (e) { }
      return canPlay;
    };

    /**
     * Pass in controller name so we can set active location in menu
     * @param {String} name The name of the controller
     */
    var changeControllerName = function(name) {
      $rootScope.controllerName = name;
    };

    /**
     * Pass whether this is a bCourses app context or not.
     */
    var checkIsBcourses = function() {
      $rootScope.isBcourses = $route.current.isBcourses;
    };

    /**
     * Hide the off canvas menu
     */
    var hideOffCanvasMenu = function() {
      $rootScope.offCanvasMenu = {
        show: false
      };
    };

    /**
     * Check whether CalCentral is being loaded within an iframe
     */
    var isInIframe = !!window.parent.frames.length;

    /**
     * Check if browser supports localStorage
     */
    var supportsLocalStorage = (function() {
      try {
        return 'localStorage' in window && window.localStorage !== null;
      } catch (e) {
        return false;
      }
    })();

    /**
     * Redirect to a page
     */
    var redirect = function(page) {
      $location.path('/' + page);
    };

    /**
     * Redirect to settings page
     */
    var redirectToSettings = function() {
      window.location = '/settings';
    };

    /**
     * Prevent a click event from bubbling up to its parents
     */
    var preventBubble = function($event) {
      // We don't need to do anything when you hit the enter key.
      // In that instance the event will be undefined.
      if (!$event) {
        return;
      }

      $event.stopPropagation();
      // When it's not an anchor tag or within an anchor tag, we also prevent the default event
      if ($event.target.nodeName !== 'A' && $event.target.parentElement.nodeName !== 'A') {
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

    /**
     * Post a message to the parent
     * @param {String|Object} message Message you want to send over.
     */
    var iframePostMessage = function(message) {
      if ($window.parent) {
        $window.parent.postMessage(message, '*');
      }
    };

    /**
     * Update the iframe height on a regular basis to avoid embedded scrollbars on
     * bCourses LTI tools. The message is formatted to be received by a listener
     * in Canvas's public/javascripts/tool_inline.js file; unless it exceeds the
     * Canvas 5000px limit, in which case our own listener handles it.
     *
     * See bc-iframe-resize directive for easy application to Canvas embedded LTI Tools
     *
     * @param  {Object}    alternativeElement         DOM element that provides scrollHeight used to resize iframe
     */
    var iframeUpdateHeight = function(alternativeElement) {
      if (isInIframe) {
        $window.setInterval(function updateHeight() {
          var heightElement = document.body;
          // use element argument to provide scrollHeight rather than body
          if (alternativeElement !== undefined && alternativeElement[0] !== undefined) {
            heightElement = alternativeElement[0];
          }
          var frameHeight = heightElement.scrollHeight;
          var messageSubject = frameHeight > 5000 ? 'resizeLargeFrame' : 'lti.frameResize';
          var message = {subject: messageSubject, height: frameHeight};
          iframePostMessage(JSON.stringify(message));
        }, 250);
      }
    };

    /**
     * Send a message triggering the parent page to scroll to the top.
     * Assumes iframe environment only applies to bCourses / Canvas LTI
     */
    var iframeScrollToTop = function() {
      if (isInIframe) {
        iframePostMessage(JSON.stringify({subject: 'changeParent', scrollToTop: true}));
      } else {
        $window.scrollTo(0, 0);
      }
    };

    /**
     * Change location of parent window
     */
    var iframeParentLocation = function(location) {
      if (isInIframe) {
        iframePostMessage(JSON.stringify({subject: 'changeParent', parentLocation: location}));
      }
    };

    /**
     * Replaces '/' and '%2F' with '_slash_' to appease Apache. See CLC-4279.
     * We can remove this once Apache is updated and allows 'AllowEncodedSlashes NoDecode'
     */
    var encodeSlash = function(string) {
      return string.replace(/\/|%2F/g, '_slash_');
    };

    var printPage = function() {
      $window.print();
    };

    var uidPattern = /^[0-9]{1,9}$/;

    // Expose methods
    return {
      canPlayMp3: canPlayMp3,
      changeControllerName: changeControllerName,
      checkIsBcourses: checkIsBcourses,
      encodeSlash: encodeSlash,
      iframeScrollToTop: iframeScrollToTop,
      iframeUpdateHeight: iframeUpdateHeight,
      iframeParentLocation: iframeParentLocation,
      isInIframe: isInIframe,
      hideOffCanvasMenu: hideOffCanvasMenu,
      naturalSort: naturalSort,
      preventBubble: preventBubble,
      printPage: printPage,
      redirect: redirect,
      redirectToSettings: redirectToSettings,
      setTitle: setTitle,
      supportsLocalStorage: supportsLocalStorage,
      uidPattern: uidPattern
    };
  });
}(window.angular, window.naturalSort));
