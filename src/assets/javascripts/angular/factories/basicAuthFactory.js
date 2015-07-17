'use strict';

var angular = require('angular');

/**
 * Admin Factory
 */
angular.module('calcentral.factories').factory('basicAuthFactory', function(apiService, $http) {
  var loginUrl = '/basic_auth_login';

  var login = function(options) {
    return apiService.http.request(options, loginUrl);
  };

  var updateHeaders = function(basicauth) {
    if (!window.btoa) {
      return;
    }
    $http.defaults.headers.common.Authorization = 'Basic ' + btoa(basicauth.login + ':' + basicauth.password);
  };

  return {
    login: login,
    updateHeaders: updateHeaders
  };
});
