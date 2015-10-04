'use strict';

var angular = require('angular');

/**
 * Profile Factory
 */
angular.module('calcentral.factories').factory('profileFactory', function(apiService, $http) {
  var urlAddressFields = '/api/campus_solutions/address_label';
  var urlCountries = '/api/campus_solutions/country';
  var urlPerson = '/api/edos/student';
  var urlTypes = '/api/campus_solutions/translate';
  var urlTypesAddress = '/api/campus_solutions/address_type';
  var urlTypesEmail = urlTypes + '?field_name=E_ADDR_TYPE';
  var urlTypesPhone = urlTypes + '?field_name=PHONE_TYPE';

  var urlPostEmail = '/api/campus_solutions/email';
  var urlPostPhone = '/api/campus_solutions/phone';

  var deleteEmail = function(options) {
    return $http.delete(urlPostEmail + '/' + options.type, options);
  };
  var deletePhone = function(options) {
    return $http.delete(urlPostPhone + '/' + options.type, options);
  };

  var getAddressFields = function(options) {
    return apiService.http.request(options, urlAddressFields + '?country=' + options.country);
  };
  var getCountries = function(options) {
    return apiService.http.request(options, urlCountries);
  };
  var getPerson = function(options) {
    return apiService.http.request(options, urlPerson);
  };

  var getTypesAddress = function(options) {
    return apiService.http.request(options, urlTypesAddress);
  };
  var getTypesEmail = function(options) {
    return apiService.http.request(options, urlTypesEmail);
  };
  var getTypesPhone = function(options) {
    return apiService.http.request(options, urlTypesPhone);
  };

  var postEmail = function(options) {
    return $http.post(urlPostEmail, options);
  };
  var postPhone = function(options) {
    return $http.post(urlPostPhone, options);
  };

  return {
    deleteEmail: deleteEmail,
    deletePhone: deletePhone,
    getCountries: getCountries,
    getAddressFields: getAddressFields,
    getPerson: getPerson,
    getTypesAddress: getTypesAddress,
    getTypesEmail: getTypesEmail,
    getTypesPhone: getTypesPhone,
    postEmail: postEmail,
    postPhone: postPhone
  };
});
