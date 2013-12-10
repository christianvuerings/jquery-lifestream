(function(angular, win) {

  'use strict';

  /**
   * We make sure to hide the location bar on mobile devices.
   * NOTE: This will only happen when the actual content is high enough.
   */
  angular.module('calcentral.services').factory('locationbarInterceptorService', function($window) {

    return {

      response: function(response) {
        // We make sure to only scroll when the user hasn't scrolled before
        if (!win.pageYOffset) {
          $window.scrollTo(0, 1);
        }
        return response;
      }

    };

  });

}(window.angular, window));
