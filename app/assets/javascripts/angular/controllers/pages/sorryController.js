(function(calcentral) {
  'use strict';

  /**
   * Error controller
   */
  calcentral.controller('SorryController', ['apiService', function(apiService) {

    apiService.util.setTitle('Sorry');

  }]);

})(window.calcentral);
