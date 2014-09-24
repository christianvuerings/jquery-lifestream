/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Add User to Course LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseAddUserController', function(apiService, canvasCourseAddUserFactory, $routeParams, $scope) {

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

      canvasCourseAddUserFactory.searchUsers($scope.canvas_course_id, $scope.search_text, $scope.search_type).success(function(data) {
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

      canvasCourseAddUserFactory.addUser(submittedUser.ldap_uid, submittedSection.id, submittedRole.id).success(function(data) {
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
      canvasCourseAddUserFactory.courseUserRoles($routeParams.canvas_course_id).success(function(data) {
        $scope.courseUserRoles = data.roles;
        $scope.grantingRoles = data.grantingRoles;
        $scope.selectedRole = $scope.grantingRoles[0];

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
      canvasCourseAddUserFactory.courseSections().success(function(data) {
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
