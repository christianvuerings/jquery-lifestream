(function(calcentral) {
  'use strict';

  /**
   * Settings controller
   */
  calcentral.controller('SettingsController', ['titleService', function(titleService) {

    titleService.setTitle('Settings');

  }]);

})(window.calcentral);
