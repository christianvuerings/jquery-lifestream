(function(angular) {
  'use strict';

  /**
   * Error controller
   */
  angular.module('calcentral.controllers').controller('ErrorController', function(apiService) {

    apiService.util.setTitle('Error');

  });

})(window.angular);
