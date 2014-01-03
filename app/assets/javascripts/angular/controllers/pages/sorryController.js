(function(angular) {
  'use strict';

  /**
   * Error controller
   */
  angular.module('calcentral.controllers').controller('SorryController', function(apiService) {

    apiService.util.setTitle('Sorry');

  });

})(window.angular);
