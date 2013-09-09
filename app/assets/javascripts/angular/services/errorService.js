(function(angular, calcentral_config, Raven) {

  'use strict';

  angular.module('calcentral.services').service('errorService', [function() {

    Raven.config(calcentral_config.sentry_url).install();

    var findElement = function(id) {
      var element = document.getElementById(id);
      if (element && element.innerHTML) {
        return element.innerHTML;
      }
    };

    /**
     * Send an error exception
     * @param {String} exception, tags The exception label to send,
     * followed by a hash of tags we want to capture in Sentry.
     */
    var send = function(exception) {
      exception = exception.message || exception;
      var uid = findElement('cc-footer-uid');
      var act_as_uid = findElement('cc-footer-actingas-uid');

      Raven.captureMessage(exception, {
        tags: {
          act_as_uid: act_as_uid,
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
