(function(calcentral) {
  'use strict';

  /**
   * Splash controller
   */
  calcentral.controller('SplashController', ['titleService', function(titleService) {

    titleService.setTitle('Home');

  }]);

})(window.calcentral);
