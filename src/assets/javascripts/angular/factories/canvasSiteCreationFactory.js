'use strict';

var angular = require('angular');

/**
 * Canvas Site Creation Factory - API Interface for 'Create a Site' overview index page
 */
angular.module('calcentral.factories').factory('canvasSiteCreationFactory', function($http) {
  var getAuthorizations = function() {
    return $http.get('/api/academics/canvas/site_creation/authorizations');
  };

  return {
    getAuthorizations: getAuthorizations
  };
});
