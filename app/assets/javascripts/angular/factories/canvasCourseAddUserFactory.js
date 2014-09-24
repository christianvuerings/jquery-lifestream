/* jshint camelcase: false */
(function(angular) {

  'use strict';

  /**
   * Canvas Course Add User Factory - Interface for 'Find a Person to Add' tool API endpoints
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('canvasCourseAddUserFactory', function($http) {

    var searchUsers = function(canvasCourseId, searchText, searchType) {
      return $http.get('/api/academics/canvas/course_add_user/search_users', {
        params: {
          canvas_course_id: canvasCourseId,
          search_text: searchText,
          search_type: searchType
        }
      });
    };

    var courseUserRoles = function(canvasCourseId) {
      var parameters = {};
      if (canvasCourseId) {
        parameters.canvas_course_id = canvasCourseId;
      }
      return $http.get('/api/academics/canvas/course_user_roles', {
        params: parameters
      });
    };

    var courseSections = function() {
      return $http.get('/api/academics/canvas/course_add_user/course_sections');
    };

    var addUser = function(ldapUserId, sectionId, roleId) {
      return $http.post('/api/academics/canvas/course_add_user/add_user', {
        ldap_user_id: ldapUserId,
        section_id: sectionId,
        role_id: roleId
      });
    };

    return {
      searchUsers: searchUsers,
      courseUserRoles: courseUserRoles,
      courseSections: courseSections,
      addUser: addUser
    };

  });

}(window.angular));
