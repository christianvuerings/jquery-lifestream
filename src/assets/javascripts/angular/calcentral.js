'use strict';

var angular = require('angular');

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
angular.module('calcentral', [
  'calcentral.config',
  'calcentral.controllers',
  'calcentral.directives',
  'calcentral.factories',
  'calcentral.filters',
  'calcentral.services',
  'ngRoute',
  'ngSanitize',
  'ngTouch',
  'templates'
]);

/**
 * Inject the CalCentral config as a constant that can be use accross modules
 */
var injectConfigConstant = function(response) {
  angular.module('calcentral.config').constant('calcentralConfig', response.data);
};

/**
 * Bootstrap the CalCentral Angular App
 */
var bootstrap = function() {
  angular.element(document).ready(function() {
    angular.bootstrap(document, ['calcentral']);
  });
};

/**
 * Load the CalCentral config which includes:
 *   csrf tokens
 *   uid
 *   google analytics id
 *   app version
 *   hostname
 */
var loadConfig = function() {
  var initInjector = angular.injector(['ng']);
  var $http = initInjector.get('$http');

  return $http.get('/api/config');
};

loadConfig().then(injectConfigConstant).then(bootstrap);
