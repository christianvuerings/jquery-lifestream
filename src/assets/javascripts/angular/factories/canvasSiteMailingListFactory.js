(function(angular) {
  'use strict';

  /**
   * Canvas Site Mailing List Factory - Interface for 'Manage a bCourses Site Mailing List' tool API endpoints
   */
  angular.module('calcentral.factories').factory('canvasSiteMailingListFactory', function($http) {
    var deleteSiteMailingList = function(canvasCourseId) {
      return $http.post('/api/academics/canvas/mailing_lists/' + canvasCourseId + '/delete');
    };

    var getSiteMailingList = function(canvasCourseId) {
      return $http.get('/api/academics/canvas/mailing_lists/' + canvasCourseId);
    };

    var populateSiteMailingList = function(canvasCourseId) {
      return $http.post('/api/academics/canvas/mailing_lists/' + canvasCourseId + '/populate');
    };

    var registerSiteMailingList = function(canvasCourseId, listName) {
      return $http.post('/api/academics/canvas/mailing_lists/' + canvasCourseId + '/create', {
        listName: listName
      });
    };

    return {
      deleteSiteMailingList: deleteSiteMailingList,
      getSiteMailingList: getSiteMailingList,
      populateSiteMailingList: populateSiteMailingList,
      registerSiteMailingList: registerSiteMailingList
    };
  });
}(window.angular));
