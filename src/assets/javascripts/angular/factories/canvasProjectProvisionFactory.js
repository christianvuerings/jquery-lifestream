(function(angular) {
  'use strict';

  /**
   * Canvas Project Provision Factory - API Interface for 'Create a Project Site' tool
   */
  angular.module('calcentral.factories').factory('canvasProjectProvisionFactory', function($http) {
    /*
     * Sends request to create project site
     */
    var createProjectSite = function(siteName) {
      return $http.post('/api/academics/canvas/project_provision/create', {
        name: siteName
      });
    };

    return {
      createProjectSite: createProjectSite
    };
  });
}(window.angular));
