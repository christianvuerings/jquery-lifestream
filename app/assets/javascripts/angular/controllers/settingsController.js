(function(calcentral) {
  'use strict';

  /**
   * Settings controller
   */
  calcentral.controller('SettingsController', ['apiService', function(apiService) {

    apiService.util.setTitle('Settings');

  }]);

})(window.calcentral);
