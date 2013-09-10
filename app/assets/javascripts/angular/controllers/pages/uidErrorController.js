(function(calcentral) {
  'use strict';

  /**
   * UID Error controller
   */
  calcentral.controller('uidErrorController', ['apiService', function(apiService) {

    apiService.util.setTitle('Unrecognized Log-in');

  }]);

})(window.calcentral);
