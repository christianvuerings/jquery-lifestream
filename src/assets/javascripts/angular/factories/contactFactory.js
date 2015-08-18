'use strict';

var angular = require('angular');

/**
 * Contact Factory
 */
angular.module('calcentral.factories').factory('contactFactory', function(apiService) {
  var urlEmails = '/dummy/json/emails.json';

  var getEmails = function(options) {
    return apiService.http.request(options, urlEmails);
  };

  return {
    getEmails: getEmails
  };
});
