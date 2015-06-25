(function(angular) {
  'use strict';

  angular.module('calcentral.services').service('errorService', function(calcentralConfig) {
    var Raven = require('raven-js');
    Raven.config(calcentralConfig.sentryUrl).install();

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
      var actAsUid = findElement('cc-footer-actingas-uid');

      Raven.captureMessage(exception, {
        tags: {
          actAsUid: actAsUid,
          appVersion: calcentralConfig.applicationVersion,
          host: calcentralConfig.clientHostname,
          uid: uid
        }
      });
    };

    // Expose methods
    return {
      send: send
    };
  });
}(window.angular));
