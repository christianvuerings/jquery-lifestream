/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Add User to Course LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseAddUserController', function(apiService, $http, $routeParams, $scope) {

    apiService.util.setTitle('Find a Person to Add');

    var resetSearchState = function() {
      $scope.selectedUser = null;
      $scope.showUsersArea = false;
      $scope.userSearchResultsCount = 0;
      $scope.noSearchTextAlert = false;
      $scope.noSearchResultsNotice = false;
      $scope.noUserSelectedAlert = false;
    };

    var resetImportState = function() {
      $scope.user_added = false;
      $scope.showAlerts = false;
      $scope.additionSuccessMessage = false;
      $scope.additionFailureMessage = false;
    };

    $scope.resetForm = function() {
      $scope.searchTextType = 'text';
      $scope.search_text = '';
      $scope.searchTypeNotice = '';
      $scope.showAlerts = false;
      resetSearchState();
      resetImportState();
    };

    var setSearchTypeNotice = function() {
      if ($scope.search_type === 'ldap_user_id') {
        $scope.searchTypeNotice = 'CalNet UIDs must be an exact match.';
      } else {
        $scope.searchTypeNotice = '';
      }
    };

    // Initialize upon load
    $scope.resetForm();
    $scope.search_type = 'name';
    $scope.userRoles = [
      {
        id: 'StudentEnrollment',
        name: 'Student'
      },
      {
        id: 'TeacherEnrollment',
        name: 'Teacher'
      },
      {
        id: 'TaEnrollment',
        name: 'TA'
      },
      {
        id: 'DesignerEnrollment',
        name: 'Designer'
      },
      {
        id: 'ObserverEnrollment',
        name: 'Observer'
      }
    ];
    $scope.selectedRole = $scope.userRoles[0];

    var invalidSearchForm = function() {
      if ($scope.search_text === '') {
        $scope.showAlerts = true;
        $scope.noSearchTextAlert = true;
        $scope.isLoading = false;
        return true;
      }
      return false;
    };

    var invalidAddUserForm = function() {
      if ($scope.selectedUser === null) {
        $scope.noUserSelectedAlert = true;
        $scope.showAlerts = true;
        return true;
      }
      $scope.noUserSelectedAlert = false;
      return false;
    };

    $scope.updateSearchTextType = function() {
      $scope.searchTextType = (['ldap_user_id'].indexOf($scope.search_type) === -1) ? 'text' : 'number';
    };

    $scope.searchUsers = function() {
      resetSearchState();
      resetImportState();

      if (invalidSearchForm()) {
        return false;
      }

      $scope.showUsersArea = true;
      $scope.isLoading = true;

      var searchUsersUri = '/api/academics/canvas/course_add_user/search_users';
      var feedParams = {
        'canvas_course_id': $scope.canvas_course_id,
        'search_text': $scope.search_text,
        'search_type': $scope.search_type
      };
      $http({
        url: searchUsersUri,
        method: 'GET',
        params: feedParams
      }).success(function(data) {
        $scope.userSearchResults = data.users;
        if (data.users.length > 0) {
          $scope.userSearchResultsCount = Math.floor(data.users[0].result_count);
          if (data.users.length === 1) {
            $scope.selectedUser = data.users[0];
          }
        } else {
          setSearchTypeNotice();
          $scope.userSearchResultsCount = 0;
          $scope.noSearchResultsNotice = true;
        }
        $scope.isLoading = false;
        $scope.showAlerts = true;
      }).error(function(data) {
        $scope.showError = true;
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'User search failed.';
        }
        $scope.isLoading = false;
        $scope.showAlerts = true;
      });
    };

    $scope.addUser = function() {
      if (invalidAddUserForm()) {
        return false;
      }
      $scope.showUsersArea = false;
      $scope.isLoading = true;
      $scope.showAlerts = true;
      var submittedUser = $scope.selectedUser;
      var submittedSection = $scope.selectedSection;
      var submittedRole = $scope.selectedRole;
      var addUserUri = '/api/academics/canvas/course_add_user/add_user';
      var addUserParams = {
        ldap_user_id: submittedUser.ldap_uid,
        section_id: submittedSection.id,
        role_id: submittedRole.id
      };
      $http({
        url: addUserUri,
        method: 'POST',
        params: addUserParams
      }).success(function(data) {
        $scope.user_added = data.user_added;
        $scope.user_added.fullName = submittedUser.first_name + ' ' + submittedUser.last_name;
        $scope.user_added.role_name = submittedRole.name;
        $scope.user_added.section_name = submittedSection.name;
        $scope.additionSuccessMessage = true;
        $scope.isLoading = false;
      }).error(function(data) {
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Request to add user failed';
        }
        $scope.additionFailureMessage = true;
        $scope.isLoading = false;
      });

    };

    var checkAuthorization = function() {
      var courseUserRolesUri = '/api/academics/canvas/course_user_roles';
      var courseUserRolesParams = {};
      if ($routeParams.canvas_course_id) {
        courseUserRolesParams.canvas_course_id = $routeParams.canvas_course_id;
      }
      $http({
        url: courseUserRolesUri,
        method: 'GET',
        params: courseUserRolesParams
      }).success(function(data) {
        $scope.courseUserRoles = data.roles;
        $scope.canvasCourseId = data.courseId;
        $scope.userAuthorized = userIsAuthorized($scope.courseUserRoles);
        if ($scope.userAuthorized) {
          getCourseSections();
          $scope.showSearchForm = true;
        } else {
          $scope.showError = true;
          $scope.errorStatus = 'You must be a teacher in this bCourses course to import users.';
        }
      }).error(function(data) {
        $scope.userAuthorized = false;
        $scope.showError = true;
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Authorization Check Failed';
        }
      });
    };

    var getCourseSections = function() {
      var courseSectionsUri = '/api/academics/canvas/course_add_user/course_sections';
      $http({
        url: courseSectionsUri,
        method: 'GET'
      }).success(function(data) {
        $scope.courseSections = data.course_sections;
        $scope.selectedSection = $scope.courseSections[0];
      }).error(function(data) {
        $scope.showError = true;
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Course sections failed to load';
        }
      });
    };

    var userIsAuthorized = function(courseUserRoles) {
      if (courseUserRoles.globalAdmin || courseUserRoles.teacher || courseUserRoles.ta || courseUserRoles.designer) {
        return true;
      }
      return false;
    };

    apiService.util.iframeUpdateHeight();
    checkAuthorization();
  });

})(window.angular);
