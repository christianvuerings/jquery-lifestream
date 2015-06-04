(function(win, angular) {
  'use strict';

  /**
   * Initialize all of the submodules
   */
  angular.module('calcentral.config', ['ngRoute']);
  angular.module('calcentral.controllers', []);
  angular.module('calcentral.directives', []);
  angular.module('calcentral.factories', []);
  angular.module('calcentral.filters', []);
  angular.module('calcentral.services', ['ng']);

  /**
   * CalCentral module
   */
  var calcentral = angular.module('calcentral', [
    'calcentral.config',
    'calcentral.controllers',
    'calcentral.directives',
    'calcentral.factories',
    'calcentral.filters',
    'calcentral.services',
    'ngAria',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'templates'
  ]);

  // Bind calcentral to the window object so it's globally accessible
  win.calcentral = calcentral;
})(window, window.angular);
