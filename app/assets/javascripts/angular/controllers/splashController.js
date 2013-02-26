(function(calcentral) {
  'use strict';

  /**
   * Splash controller
   */
  calcentral.controller('SplashController', ['apiService', function(apiService) {
    apiService.util.setTitle('Home');
  }]);

})(window.calcentral);
