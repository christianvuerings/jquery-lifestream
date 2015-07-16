'use strict';

var angular = require('angular');

/**
 * Tools Factory
 */
angular.module('calcentral.factories').factory('toolsFactory', function(apiService) {
  var stylesUrl = '/api/tools/styles';

  var getStyles = function(options) {
    return apiService.http.request(options, stylesUrl);
  };

  return {
    getStyles: getStyles
  };
});
