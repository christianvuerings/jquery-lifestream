'use strict';

var angular = require('angular');

/**
 * Profile Factory
 */
angular.module('calcentral.factories').factory('profileFactory', function(apiService, $http) {
  var urlTypes = '/api/campus_solutions/translate';
  var urlTypesEmail = urlTypes + '?field_name=E_ADDR_TYPE';
  var urlTypesPhone = urlTypes + '?field_name=PHONE_TYPE';
  var urlPerson = '/api/edos/student';

  var urlPostEmail = '/api/campus_solutions/email';
  var urlPostPhone = '/api/campus_solutions/phone';

  var getEmailTypes = function(options) {
    return apiService.http.request(options, urlTypesEmail);
  };
  var getPerson = function(options) {
    return apiService.http.request(options, urlPerson);
  };
  var getPhoneTypes = function(options) {
    return apiService.http.request(options, urlTypesPhone);
  };

  var postEmail = function(options) {
    return $http.post(urlPostEmail, options);
  };
  var postPhone = function(options) {
    return $http.post(urlPostPhone, options);
  };

  return {
    getEmailTypes: getEmailTypes,
    getPerson: getPerson,
    getPhoneTypes: getPhoneTypes,
    postEmail: postEmail,
    postPhone: postPhone
  };
});
