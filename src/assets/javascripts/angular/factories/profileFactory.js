'use strict';

var angular = require('angular');

/**
 * Profile Factory
 */
angular.module('calcentral.factories').factory('profileFactory', function(apiService, $http) {
  var urlEmailTypes = '/api/campus_solutions/translate?field_name=E_ADDR_TYPE';
  var urlPerson = '/api/edos/person';

  var urlPostEmail = '/api/campus_solutions/email';

  var getEmailTypes = function(options) {
    return apiService.http.request(options, urlEmailTypes);
  };
  var getPerson = function(options) {
    return apiService.http.request(options, urlPerson);
  };

  var postEmail = function(options) {
    return $http.post(urlPostEmail, options);
  };

  return {
    getEmailTypes: getEmailTypes,
    getPerson: getPerson,
    postEmail: postEmail
  };
});
