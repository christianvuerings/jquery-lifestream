(function(calcentral) {
  'use strict';

  /**
   * Error controller
   */
  calcentral.controller('ErrorController', ['apiService', function(apiService) {

    apiService.util.setTitle('Error');

  }]);

})(window.calcentral);
