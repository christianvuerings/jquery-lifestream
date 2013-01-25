(function(calcentral) {
  'use strict';

  /**
   * Error controller
   */
  calcentral.controller('ErrorController', ['titleService', function(titleService) {

    titleService.setTitle('Error');

  }]);

})(window.calcentral);
