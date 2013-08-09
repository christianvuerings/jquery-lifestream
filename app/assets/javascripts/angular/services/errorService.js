(function(angular, calcentral_config, Raven) {

  'use strict';

  angular.module('calcentral.services').service('errorService', [function() {

    Raven.config(calcentral_config.sentry_url).install();

    /**
     * Send an error exception
     * @param {String} exception, tags The exception label to send,
     * followed by a hash of tags we want to capture in Sentry.
     */

    var send = function(exception) {
      exception = exception.message || exception;
      var userIdElement = document.getElementById('user_id');
      var uid;
      if (userIdElement && userIdElement.innerHTML) {
        uid = userIdElement.innerHTML;
      }

      Raven.captureMessage(exception, {
        tags: {
          app_version: calcentral_config.application_version,
          host: calcentral_config.client_hostname,
          uid: uid
        }
      });
    };

    // Expose methods
    return {
      send: send
    };

  }]);

}(window.angular, window.calcentral_config, window.Raven));
