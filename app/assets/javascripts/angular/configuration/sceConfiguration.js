/**
 * Set the SCE configuration for CalCentral
 */
(function(calcentral) {

  'use strict';

  // Set the configuration
  calcentral.config(['$sceDelegateProvider', function($sceDelegateProvider) {

    $sceDelegateProvider.resourceUrlWhitelist([
      'self',
      'http://www.youtube.com/**'
    ]);

  }]);

})(window.calcentral);
