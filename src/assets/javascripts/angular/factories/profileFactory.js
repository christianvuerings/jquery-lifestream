'use strict';

var angular = require('angular');

/**
 * Profile Factory
 */
angular.module('calcentral.factories').factory('profileFactory', function(apiService, $http) {
  var urlAddressFields = '/api/campus_solutions/address_label';
  var urlCountries = '/api/campus_solutions/country';
  var urlPerson = '/api/edos/student';
  var urlStates = '/api/campus_solutions/state';
  var urlTypes = '/api/campus_solutions/translate';
  var urlTypesAddress = '/api/campus_solutions/address_type';
  var urlTypesEmail = urlTypes + '?field_name=E_ADDR_TYPE';
  var urlTypesPhone = urlTypes + '?field_name=PHONE_TYPE';

  var urlPostAddress = '/api/campus_solutions/address';
  var urlPostEmail = '/api/campus_solutions/email';
  var urlPostPhone = '/api/campus_solutions/phone';

  // Delete
  var deleteAddress = function(options) {
    return $http.delete(urlPostAddress + '/' + options.type, options);
  };
  var deleteEmail = function(options) {
    return $http.delete(urlPostEmail + '/' + options.type, options);
  };
  var deletePhone = function(options) {
    return $http.delete(urlPostPhone + '/' + options.type, options);
  };

  // Get - General
  var getAddressFields = function(options) {
    return apiService.http.request(options, urlAddressFields + '?country=' + options.country);
  };
  var getCountries = function(options) {
    return apiService.http.request(options, urlCountries);
  };
  var getPerson = function(options) {
    return apiService.http.request(options, urlPerson);
  };
  var getStates = function(options) {
    return apiService.http.request(options, urlStates + '?country=' + options.country);
  };

  // Get - Types
  var getTypesAddress = function(options) {
    return apiService.http.request(options, urlTypesAddress);
  };
  var getTypesEmail = function(options) {
    return apiService.http.request(options, urlTypesEmail);
  };
  var getTypesPhone = function(options) {
    return apiService.http.request(options, urlTypesPhone);
  };

  // Post
  var postAddress = function(options) {
    return $http.post(urlPostAddress, options);
  };
  var postEmail = function(options) {
    return $http.post(urlPostEmail, options);
  };
  var postPhone = function(options) {
    return $http.post(urlPostPhone, options);
  };

  return {
    deleteAddress: deleteAddress,
    deleteEmail: deleteEmail,
    deletePhone: deletePhone,
    getCountries: getCountries,
    getAddressFields: getAddressFields,
    getPerson: getPerson,
    getStates: getStates,
    getTypesAddress: getTypesAddress,
    getTypesEmail: getTypesEmail,
    getTypesPhone: getTypesPhone,
    postAddress: postAddress,
    postEmail: postEmail,
    postPhone: postPhone
  };
});
