'use strict';

var angular = require('angular');

/**
 * Server Info Factory
 */
angular.module('calcentral.factories').factory('serverInfoFactory', function(apiService) {
  var url = '/api/server_info';

  var getServerInfo = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getServerInfo: getServerInfo
  };
});
