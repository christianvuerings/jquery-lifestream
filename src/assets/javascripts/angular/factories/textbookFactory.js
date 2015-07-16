'use strict';

var angular = require('angular');

/**
 * Textbook Factory
 */
angular.module('calcentral.factories').factory('textbookFactory', function(apiService) {
  // var url = '/dummy/json/textbooks_details.json';
  var url = '/api/my/textbooks_details';

  var getTextbooks = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getTextbooks: getTextbooks
  };
});
