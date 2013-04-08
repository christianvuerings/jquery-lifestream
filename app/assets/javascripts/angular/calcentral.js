(function(window, angular) {

  'use strict';

  /**
   * Initialize all of the submodules
   */
  angular.module('calcentral.directives', []);
  angular.module('calcentral.filters', []);
  angular.module('calcentral.services', ['ng']);

  /**
   * CalCentral module
   */
  var calcentral = angular.module('calcentral', [
    'calcentral.directives',
    'calcentral.filters',
    'calcentral.services',
    'ngSanitize'
  ]);

  // Bind calcentral to the window object so it's globally accessible
  window.calcentral = calcentral;

})(window, window.angular);
